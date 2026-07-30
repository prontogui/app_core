// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// All rights reserved. Use of this source code is governed by the
// proprietary license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:dartlib/log.dart';

/// An event that was parsed from a log file.
class EventLogItem {
  EventLogItem(this.windowKey, this.eventTime, this.eventType, this.message) : _markedForRemoval = false;

  final String windowKey;
  final DateTime eventTime;
  final String eventType;
  final String message;
  bool _markedForRemoval;
}

/// Everything we are tracking for a window's worth of log files.
class _WindowTrackingRecord {
  _WindowTrackingRecord(this.fileTracking);

  /// Maps Filename -> Event Count 
  final Map<String, int> fileTracking;

  /// The next file position to read from in the latest.log file.
  int latestFilePosition = 0;

  /// The total event count for this window.
  int eventItemCount = 0;
}

class _ProcessedAmounts {
  const _ProcessedAmounts(this.events, this.bytes, this.invalidLogEntries);
  final int events;
  final int bytes;
  final int invalidLogEntries;
}

/// Status information returned from retrieving events for a window.
class _WindowRetrievalStatus {
  const _WindowRetrievalStatus({
    required this.eventsAdded,
    required this.eventsRemoved,
  });

  final bool eventsAdded;
  final bool eventsRemoved;

  bool get hasChanged => eventsAdded || eventsRemoved;
}

/// A data view that can be used to show event log items. 
class EventLogDataView {

  // Constructor
  EventLogDataView({String? altLogsRootPath, int readChunkSize = 4096}) {
    _logsRootPath = (altLogsRootPath != null) ? altLogsRootPath : logsRootPath;  // From dartlib
    _matchLogEntry = RegExp(r'^\[([a-zA-Z]+)\] TIME: ([^ ]+) (.+)');
    _readChunkSize = readChunkSize;
  }

  /// Name of the latest log file
  static const String _latestLogFile = 'latest.log';

  /// Root path where log files are stored.
  late final String _logsRootPath;

  /// Size of text chunks when reading log files.
  late final int _readChunkSize;

  /// Information we track for instance windows so we can progressively update our
  /// list of event items we keep in memory.
  final _windowTracking = <String, _WindowTrackingRecord>{};

  /// All event items for instance and global windows that are ready for viewing.
  final _eventItems = List<EventLogItem>.empty(growable: true);

  /// Indices into _eventItems that pass the current filter.
  List<int> _filteredIndices = [];

  /// The current window key filter. Null means no filter (show all windows).
  String? _windowKeyFilter;

  /// Used for matching/validating each log entry before parsing
  late final RegExp _matchLogEntry;

  /// Gets the current window key filter. Null means no filter (show all windows).
  String? get windowKeyFilter => _windowKeyFilter;

  /// Sets the window key filter. Pass null to show all windows.
  set windowKeyFilter(String? value) {
    if (_windowKeyFilter != value) {
      _windowKeyFilter = value;
      _rebuildFilteredIndices();
    }
  }

  /// Rebuilds the filtered indices based on the current filter.
  void _rebuildFilteredIndices() {
    if (_windowKeyFilter == null) {
      // No filter - include all indices
      _filteredIndices = List<int>.generate(_eventItems.length, (i) => i);
    } else {
      // Filter by window key
      _filteredIndices = <int>[];
      for (int i = 0; i < _eventItems.length; i++) {
        if (_eventItems[i].windowKey == _windowKeyFilter) {
          _filteredIndices.add(i);
        }
      }
    }
  }

  /// Retrieves the latest log events for all windows.
  ///
  /// Returns true if the event log has changed (events added or removed).
  Future<bool> retrieveLatestEvents(List<String> currentWindowKeys) async {

    // If any windows were added or removed since last time then start from scratch and reload everything
    if (!setEquals(currentWindowKeys.toSet(), Set<String>.from(_windowTracking.keys))) {
      _windowTracking.clear();
      _eventItems.clear();

      for (final key in currentWindowKeys) {
        _windowTracking[key] = _WindowTrackingRecord({_latestLogFile : 0});
      }
    }

    bool eventsMarkedForRemoval = false;
    bool hasChanged = false;

    // Retrieve the latest events for each window
    for (var key in currentWindowKeys) {
      final status = await _retrieveLatestEventsForWindow(key);
      if (status.eventsRemoved) {
        eventsMarkedForRemoval = true;
      }
      if (status.hasChanged) {
        hasChanged = true;
      }
    }

    // Trim events if any have been marked for removal
    if (eventsMarkedForRemoval) {
      _eventItems.removeWhere((item) => item._markedForRemoval);
    }

    // Rebuild filtered indices after events have been updated
    _rebuildFilteredIndices();

    return hasChanged;
  }

  /// Returns the number of events that pass the current filter.
  int get eventCount => _filteredIndices.length;

  /// Get an event log item by index (filtered). Handy for ListView.builder approach.
  EventLogItem getItem(int index) {
    return _eventItems[_filteredIndices[index]];
  }

  /// Retrieves the latest events that were added for a window.
  ///
  /// This is the crux of what this class does - it handles where
  /// log files rotated and or removed from window's log folder, while
  /// efficiently keeping tracking of last read position of the latest log
  /// file, so faster random access can be used to retrieve unprocessed
  /// event information.
  ///
  /// [windowKey] is the key, or tracking identifer, for the window and
  /// is used to locate the log files.
  ///
  /// Returns status information about whether events were added or removed.
  Future<_WindowRetrievalStatus> _retrieveLatestEventsForWindow(String windowKey) async {

    // Get some tracking information
    var tracking = _windowTracking[windowKey]!;
    var latestLogEventCount = tracking.fileTracking[_latestLogFile]!;

    // Get a list of folders in the window's log folder
    final windowLogPath = path.join(_logsRootPath, windowKey);
    var prevLogFiles = Set<String>.from(tracking.fileTracking.keys);
    var currentLogFiles = await _getFolderFiles(windowLogPath);

    // Figure out if files were added
    var filesAdded = currentLogFiles!.difference(prevLogFiles).toList();
    filesAdded.sort((a, b) => a.compareTo(b));

    // Figure out if files were removed
    var filesRemoved = prevLogFiles.difference(currentLogFiles);

    // Track total events added across all processing
    int totalEventsAdded = 0;

    // Deal with the newly added files
    if (filesAdded.isNotEmpty) {

      // The oldest file added will be the rotated copy of the previous "latest" log.
      var rotatedLatestLogFile = filesAdded[0];

      // Process any remaining events in former latest.log file
      // and carry forward the previous event count for the latest log file.
      var amountsProcessed = await _processLatestLogEntries(windowKey, windowLogPath, rotatedLatestLogFile, tracking.latestFilePosition);
      tracking.fileTracking[rotatedLatestLogFile] = (amountsProcessed.events + latestLogEventCount);
      tracking.eventItemCount += amountsProcessed.events;
      totalEventsAdded += amountsProcessed.events;

      // Reset tracking info for latest log file.
      latestLogEventCount = 0;
      tracking.latestFilePosition = 0;

      // Process every additional rotation file added thereafter and update
      // tracking information.
      for (var filename in filesAdded.getRange(1, filesAdded.length)) {
        var amountsProcessed = await _processLatestLogEntries(windowKey, windowLogPath, filename, 0);
        tracking.fileTracking[filename] = amountsProcessed.events;
        tracking.eventItemCount += amountsProcessed.events;
        totalEventsAdded += amountsProcessed.events;
      }
    }

    // Deal with the recently removed files
    if (filesRemoved.isNotEmpty) {

      // Track how many events should be removed by looking at file tracking information
      int removalCount = 0;

      for (var filename in filesRemoved) {
        removalCount += tracking.fileTracking[filename]!;
        tracking.fileTracking.remove(filename);
      }

      // Mark events for removal
      for (int i = 0, count = removalCount; i < _eventItems.length && count > 0; i++) {

        final eventItem = _eventItems[i];

        if (eventItem.windowKey == windowKey) {
          eventItem._markedForRemoval = true;
          count--;
        }
      }

      // Reduce the total event item count accordingly
      tracking.eventItemCount -= removalCount;
    }

    // Process the latest log entries and update tracking information
    var amountsProcessed = await _processLatestLogEntries(windowKey, windowLogPath, _latestLogFile, tracking.latestFilePosition);
    tracking.fileTracking[_latestLogFile] = latestLogEventCount + amountsProcessed.events;
    tracking.latestFilePosition += amountsProcessed.bytes;
    tracking.eventItemCount += amountsProcessed.events;
    totalEventsAdded += amountsProcessed.events;

    return _WindowRetrievalStatus(
      eventsAdded: totalEventsAdded > 0,
      eventsRemoved: filesRemoved.isNotEmpty,
    );
  }

  /// Processes a log file and populates _eventItems with new event log information.
  /// 
  /// [windowKey] is the key, or tracking identifer, for the window and 
  /// is used to locate the log files.
  /// [logFolderPath] the folder where log files are kept.
  /// [logFileName] the name of the log file.
  /// [startingPosition] the file position where to start processing.
  /// 
  /// Returns the amounts of events and bytes that were processed.
  Future<_ProcessedAmounts> _processLatestLogEntries(String windowKey, String logFolderPath, String logFileName, int startingPosition) async {

    // Open the file
    final file = File(path.join(logFolderPath, logFileName));
    final reader = await file.open();
    await reader.setPosition(startingPosition);

    // Tracking stats
    int eventsProcessed = 0;
    int bytesProcessed = 0;
    int invalidLogEntries = 0;

    /// Processes data from the file in multiple chunks
    Future<void> processChunkByChunk() async {
      String content = '';

      for (;;) {
        // Read a chunk
        final bytes = await reader.read(_readChunkSize);
        final endOfContent = bytes.length < _readChunkSize;
        content = content + utf8.decode(bytes);

        // Break into lines
        final lines = content.split('\n');

        // Process every solid line (the last element is not a complete line)
        for (final line in lines.getRange(0, lines.length - 1)) {
          // Extract information from line
          final eventItem = _convertLogEntryToEventItem(windowKey, line);

          if (eventItem == null) {
            invalidLogEntries++;
          } else {
            _eventItems.add(eventItem);
            eventsProcessed++;
          }
        }

        // Backtrack the residual file data for the next iteration
        final residual = lines.last;
        bytesProcessed += (content.length - residual.length);
        content = residual;

        if (endOfContent) {
          break;
        }
      }
    }

    try {
      await processChunkByChunk();
    } finally {
      await reader.close();
    }

    return _ProcessedAmounts(eventsProcessed, bytesProcessed, invalidLogEntries);
  }

  /// Builds an _EventItem from an event log entry.
  /// 
  /// [windowKey] is the key, or tracking identifer, for the window and 
  /// is used to locate the log files.
  /// [logEntry] the log entry to parse.
  /// 
  /// An example of an event log entry is:
  /// ```
  /// [I] TIME: 2026-01-09T08:50:53.830171 Entered inactive state
  /// ```
  /// 
  /// Where:
  /// - `[I]` is the event type (can be [I], [E], [D], or [T])
  /// - `2026-01-09T08:50:53.830171` is the timestamp in ISO 8601 format
  /// - `Entered inactive state` is the event message
  /// 
  /// Returns an [EventLogItem] with the supplied windowKey and parsed values of eventTime,
  /// eventType, and message, or null if wasn't able to parse log entry.
  EventLogItem? _convertLogEntryToEventItem(String windowKey, String logEntry) {

    final match = _matchLogEntry.matchAsPrefix(logEntry);
    if (match == null) {
      return null;
    }
      
    final eventType = match.group(1)!;
    final eventTimeStr = match.group(2)!;
    final eventTime = DateTime.tryParse(eventTimeStr);
    if (eventTime == null) {
      return null;
    }
    final eventMsg = match.group(3)!;

    return EventLogItem(windowKey, eventTime, eventType, eventMsg);
  }

  /// Get a list of files contained in a folder.
  /// 
  /// [folderPath] the path of the folder containing files.
  /// 
  /// Returns a set of file names.
  Future<Set<String>?> _getFolderFiles(String folderPath) async {

    final logDir = Directory(folderPath);
    if (!await logDir.exists()) {
      return null;
    }

    // Get list of files in folder
    return await logDir
        .list(recursive: false, followLinks: false)
        .where((entity) => entity is File)
        .map((entity) => entity.path.split(Platform.pathSeparator).last)
        .toSet();
  }
}

