// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// All rights reserved. Use of this source code is governed by the
// proprietary license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:app_core/src/event_log_data_view.dart';

void main() {
  group('EventLogDataView', () {
    late Directory tempDir;
    late String testLogsPath;
    late EventLogDataView dataView;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('test_logs_');
      testLogsPath = tempDir.path;
      // Use alternate logsRootPath for testing
      dataView = EventLogDataView(altLogsRootPath: testLogsPath);
    });

    tearDown(() async {
      tempDir.deleteSync(recursive: true);
    });


    const lorem =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
        'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
        'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.';

    String randomLorem({int maxLength = 120}) {
      final rand = Random();
      final start = rand.nextInt(lorem.length - maxLength);
      return lorem.substring(start, start + maxLength);
    }

    String makeRandomLogEntry() {
      final itemTime = DateTime.now();
      final itemMessage = randomLorem();
      return '[I] TIME: $itemTime $itemMessage\n';
    }

    String createWindow(int windowNo) {
      final windowDir = Directory(path.join(testLogsPath, 'window$windowNo'));
      windowDir.createSync();
      return windowDir.path;
    }

    void removeWindow(int windowNo) {
      final windowDir = Directory(path.join(testLogsPath, 'window$windowNo'));
      windowDir.deleteSync(recursive: true);
    }

    String createLogFile(int windowNo, String filename, int itemCount) {
      String content = '';
      for (var i = 0; i < itemCount; i++) {
        content = content + makeRandomLogEntry();
      }
      final logFile = File(path.join(testLogsPath, 'window$windowNo', filename));
      logFile.writeAsStringSync(content);
      return logFile.path;
    }

    String rotationFileName(int rotationIndex) {
      final hour = rotationIndex.toString();
      return '2026-01-13-$hour-15-02-487.log';
    }

    void createLatestLog(int windowNo, int itemCount) {
      createLogFile(windowNo, 'latest.log', itemCount);
    }

    void appendLatestLog(int windowNo, int itemCount) {

      String content = '';
      for (var i = 0; i < itemCount; i++) {
        content = content + makeRandomLogEntry();
      }
      final logFile = File(path.join(testLogsPath, 'window$windowNo', 'latest.log'));
      final prevContent = logFile.readAsStringSync();
      logFile.writeAsStringSync(prevContent + content);
    }

    void createRotationLog(int windowNo, int rotationIndex, int itemCount) {
      // Convert rotationIndex to a timestamp filename
      createLogFile(windowNo, rotationFileName(rotationIndex), itemCount);
    }

    void removeRotationLog(int windowNo, int rotationIndex) {
      final logFile = File(path.join(testLogsPath, 'window$windowNo', rotationFileName(rotationIndex)));

      // Remove window directory
      logFile.deleteSync();
    }

    void rotateLatestLog(int windowNo, int rotationIndex) {
      final logFile = File(path.join(testLogsPath, 'window$windowNo', 'latest.log'));
      final newPath = path.join(testLogsPath, 'window$windowNo', rotationFileName(rotationIndex));
      logFile.copySync(newPath);
      createLatestLog(windowNo, 0);
    }

    List<String> getWindowKeys() {
      final logsDir = Directory(testLogsPath);
      if (!logsDir.existsSync()) return [];
      return logsDir
          .listSync()
          .whereType<Directory>()
          .map((d) => path.basename(d.path))
          .toList();
    }

    Future<void> verifyEvents(int expectCount) async {
      await dataView.retrieveLatestEvents(getWindowKeys());
      expect(dataView.eventCount, equals(expectCount));
    }

    test('Empty logs directory returns zero event count', () async {
      await verifyEvents(0);
    });

    test('Invalid log entry format is ignored', () async {
      final winPath = createWindow(1);
      
      final logFile = File(path.join(winPath, 'latest.log'));
      logFile.writeAsStringSync('Invalid log format\n[I] TIME: 2026-01-09T08:50:53.830171 Valid message\n');

      await verifyEvents(1);
    });

    test('Invalid timestamp format is ignored', () async {
      final winPath = createWindow(1);
      
      final logFile = File(path.join(winPath, 'latest.log'));
      logFile.writeAsStringSync('[I] TIME: invalid-timestamp Test message\n');

      await verifyEvents(0);
    });

    test('Different event types get correct styles', () async {
      final winPath = createWindow(1);
      
      final logFile = File(path.join(winPath, 'latest.log'));
      logFile.writeAsStringSync(
        '[I] TIME: 2026-01-09T08:50:53.830171 Info message\n'
        '[E] TIME: 2026-01-09T08:50:54.830171 Error message\n'
        '[D] TIME: 2026-01-09T08:50:55.830171 Debug message\n'
        '[T] TIME: 2026-01-09T08:50:56.830171 Trace message\n'
      );

      await verifyEvents(4);
    });

    test('Progressive loading updates existing data', () async {
      final windowDir = Directory(path.join(testLogsPath, 'window1'));
      await windowDir.create();
      
      final logFile = File(path.join(windowDir.path, 'latest.log'));
      logFile.writeAsStringSync('[I] TIME: 2026-01-09T08:50:53.830171 First message\n');

      // First load
      await verifyEvents(1);

      // Append more data
      logFile.writeAsStringSync(
        '[I] TIME: 2026-01-09T08:50:53.830171 First message\n'
        '[I] TIME: 2026-01-09T08:50:53.830171 Second message\n'
        '[E] TIME: 2026-01-09T08:51:00.000000 Third message\n'
      );

      await verifyEvents(3);
    });


    test('Progressive loading updates with rotating log files', () async {

      // Create window
      createWindow(1);
      createLatestLog(1, 3);
      createWindow(2);
      createLatestLog(2, 0);
      createWindow(3);
      createLatestLog(3, 0);

      // Do operations on Window1...

      // Create a few rotated log files
      createRotationLog(1, 0, 5);
      createRotationLog(1, 1, 3);
      createRotationLog(1, 2, 8);
      await verifyEvents(19);

      // Add a few more to latest.log
      appendLatestLog(1, 4);
      await verifyEvents(23);

      // Add a few more to latest.log
      appendLatestLog(1, 3);

      // Rotate latest.log
      rotateLatestLog(1, 3);

      // Add several more to latest.log
      appendLatestLog(1, 10);
      await verifyEvents(36);

      // Remove earliest log file
      removeRotationLog(1, 0);
      await verifyEvents(31);

      // Do operations on all windows...

      // Add more events to every window
      appendLatestLog(1, 3);
      appendLatestLog(2, 5);
      appendLatestLog(3, 7);
      await verifyEvents(46);

      // Rotate a couple windows and add a few more events
      rotateLatestLog(2, 0);
      rotateLatestLog(3, 0);
      appendLatestLog(2, 2);
      appendLatestLog(3, 6);
      await verifyEvents(54);

      // Again, rotate a couple windows and add a few more events
      rotateLatestLog(2, 1);
      rotateLatestLog(3, 1);
      appendLatestLog(2, 3);
      appendLatestLog(3, 2);
      await verifyEvents(59);

      // Again, rotate a couple windows and add a few more events
      rotateLatestLog(2, 2);
      rotateLatestLog(3, 2);
      appendLatestLog(2, 1);
      appendLatestLog(3, 2);
      await verifyEvents(62);

      // Drop earliest log files on windows 2, 3
      removeRotationLog(2, 0);
      removeRotationLog(3, 0);
      await verifyEvents(50);

      // Remove a window 1
      removeWindow(1);
      await verifyEvents(16);

      // Remove window 2
      removeWindow(2);
      await verifyEvents(10);

      // Remove window 3
      removeWindow(3);
      await verifyEvents(0);
    });

    test('Rotation files are processed in correct order', () async {
      createWindow(1);
      createLatestLog(1, 3);
      rotateLatestLog(1, 0);
      appendLatestLog(1, 5);
      rotateLatestLog(1, 1);
      appendLatestLog(1, 4);
      rotateLatestLog(1, 2);
      appendLatestLog(1, 3);
      await verifyEvents(15);
    });

    test('Filter by window key shows only that window events', () async {
      // Create multiple windows with different event counts
      createWindow(1);
      createLatestLog(1, 5);
      createWindow(2);
      createLatestLog(2, 3);
      createWindow(3);
      createLatestLog(3, 7);

      // No filter - should see all events
      await dataView.retrieveLatestEvents(getWindowKeys());
      expect(dataView.eventCount, equals(15));

      // Filter by window1
      dataView.windowKeyFilter = 'window1';
      expect(dataView.eventCount, equals(5));

      // Filter by window2
      dataView.windowKeyFilter = 'window2';
      expect(dataView.eventCount, equals(3));

      // Filter by window3
      dataView.windowKeyFilter = 'window3';
      expect(dataView.eventCount, equals(7));

      // Clear filter - should see all events again
      dataView.windowKeyFilter = null;
      expect(dataView.eventCount, equals(15));
    });

    test('Filter returns correct items via getItem', () async {
      createWindow(1);
      createWindow(2);

      // Create logs with identifiable content
      final logFile1 = File(path.join(testLogsPath, 'window1', 'latest.log'));
      logFile1.writeAsStringSync('[I] TIME: 2026-01-09T08:50:53.830171 Window1 Message\n');

      final logFile2 = File(path.join(testLogsPath, 'window2', 'latest.log'));
      logFile2.writeAsStringSync('[I] TIME: 2026-01-09T08:50:54.830171 Window2 Message\n');

      await dataView.retrieveLatestEvents(getWindowKeys());

      // Filter by window1 and verify the item
      dataView.windowKeyFilter = 'window1';
      expect(dataView.eventCount, equals(1));
      expect(dataView.getItem(0).windowKey, equals('window1'));
      expect(dataView.getItem(0).message, equals('Window1 Message'));

      // Filter by window2 and verify the item
      dataView.windowKeyFilter = 'window2';
      expect(dataView.eventCount, equals(1));
      expect(dataView.getItem(0).windowKey, equals('window2'));
      expect(dataView.getItem(0).message, equals('Window2 Message'));
    });

    test('Filter persists after retrieveLatestEvents', () async {
      createWindow(1);
      createLatestLog(1, 3);
      createWindow(2);
      createLatestLog(2, 5);

      await dataView.retrieveLatestEvents(getWindowKeys());

      // Set filter
      dataView.windowKeyFilter = 'window1';
      expect(dataView.eventCount, equals(3));

      // Add more events and retrieve again
      appendLatestLog(1, 2);
      appendLatestLog(2, 4);
      await dataView.retrieveLatestEvents(getWindowKeys());

      // Filter should still be applied
      expect(dataView.windowKeyFilter, equals('window1'));
      expect(dataView.eventCount, equals(5));
    });

    test('Filter for non-existent window returns zero events', () async {
      createWindow(1);
      createLatestLog(1, 5);

      await dataView.retrieveLatestEvents(getWindowKeys());

      dataView.windowKeyFilter = 'nonexistent';
      expect(dataView.eventCount, equals(0));
    });

    test('Empty log message is okay', () async {

      print("entering last test 2");

      // Create window1

      // Create latest log file

      // Verify

    });
  });
}