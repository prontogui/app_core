// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// All rights reserved. Use of this source code is governed by the
// proprietary license that can be found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'event_log_data_view.dart';
import 'window/window_management.dart';
import 'app_settings.dart';

const _kRefreshInterval = Duration(seconds: 30);
const _kFontFamily = 'KodeMono';
const _kFontSize = 14.0;

class EventLogApp extends StatefulWidget {
  const EventLogApp({super.key});

  @override
  State<EventLogApp> createState() => _EventLogAppState();
}

class _EventLogAppState extends State<EventLogApp> {
  @override
  void initState() {
    super.initState();
    WindowManagement.instance.notifyThemeChanged.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    WindowManagement.instance.notifyThemeChanged.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<void> _onThemeChanged() async {
    await AppSettings.instance.reload();
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Log Viewer',
      theme: AppSettings.instance.lightTheme,
      darkTheme: AppSettings.instance.darkTheme,
      themeMode: AppSettings.instance.themeMode,
      home: const Scaffold(body: EventLogViewer()),
    );
  }
}

class EventLogViewer extends StatefulWidget {
  const EventLogViewer({super.key});

  @override
  State<EventLogViewer> createState() => _EventLogViewerState();
}

class _EventLogViewerState extends State<EventLogViewer> {
  late final Timer _refreshTimer;
  late final EventLogDataView _view;
  late final ScrollController _scrollController;

  int _windowFilterSelection = 0;

  Map<int, String> _indexToTitle = {0: 'All'};
  Map<int, String> _indexToWindowKey = {0: ''};
  Map<String, String> _windowKeyToTitle = {};

  Map<String, double> _lastScrollPositions = {};

  bool _reloading = false;

  String get _windowFilterChoice => _indexToWindowKey[_windowFilterSelection]!;

  String? get _windowFilter => _windowFilterSelection == 0 ? null : _windowFilterChoice;

  @override
  void initState() {
    super.initState();

    void scrollNotification() {
      _lastScrollPositions[_windowFilterChoice] = _scrollController.position.pixels;
    }

    _scrollController = ScrollController(
      keepScrollOffset: true,
        onAttach: (position) {
          position.addListener(scrollNotification);
        },
        onDetach:(position) {
          position.removeListener(scrollNotification);
        },
      );

    _view = EventLogDataView();

    WindowManagement.instance.notifyWindowClosed.addListener(_reloadWindowChoices);
    WindowManagement.instance.notifyWindowOpened.addListener(_reloadWindowChoices);
    WindowManagement.instance.notifyWindowTitleChanged.addListener(_reloadWindowChoices);

    _refreshTimer = Timer.periodic(_kRefreshInterval, (_) => _reload());
    _initialLoad();
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    _scrollController.dispose();
    WindowManagement.instance.notifyWindowClosed.removeListener(_reloadWindowChoices);
    WindowManagement.instance.notifyWindowOpened.removeListener(_reloadWindowChoices);
    WindowManagement.instance.notifyWindowTitleChanged.removeListener(_reloadWindowChoices);
    super.dispose();
  }

  Future<void> _initialLoad() async {
    await _reloadWindowChoices();
    _view.windowKeyFilter = _windowFilter;
    await _reload();
  }

  Future<void> _reload() async {
    if (_reloading) {
      return;
    }
    _reloading = true;
    try {
      final hasChanges = await _view.retrieveLatestEvents(_windowKeyToTitle.keys.toList());
      if (hasChanges) {
        setState((){
        });
      }
    } catch (_) {
    } finally {
      _reloading = false;
    }
  }

  late TextStyle _defaultTextStyle;
  late TextStyle _regularStyle;
  late TextStyle _windowTitleStyle;
  late TextStyle _errorEventStyle;
  late TextStyle _debugEventStyle;
  late TextStyle _traceEventStyle;
  late TextStyle _fatalEventStyle;
  late TextStyle _infoEventStyle;
  late TextSpan _space;

  void _prepareStylesAndPieces() {

    _defaultTextStyle = DefaultTextStyle.of(context).style;

    _regularStyle = TextStyle(
      color: _defaultTextStyle.color,
      fontFamily: _kFontFamily,
      fontSize: _kFontSize,
    );

    _windowTitleStyle = TextStyle(
      color: Colors.black,
      backgroundColor: Colors.grey,
      fontFamily: _kFontFamily,
      fontSize: _kFontSize,
    );

    _errorEventStyle = TextStyle(
      color: Colors.redAccent,
      fontFamily: _kFontFamily,
      fontSize: _kFontSize,
    );

    _debugEventStyle = TextStyle(
      color: Colors.purpleAccent,
      fontFamily: _kFontFamily,
      fontSize: _kFontSize,
    );

    _traceEventStyle = TextStyle(
      color: Colors.blueGrey,
      fontFamily: _kFontFamily,
      fontSize: _kFontSize,
    );

    _fatalEventStyle = TextStyle(
      color: Colors.brown,
      fontFamily: _kFontFamily,
      fontSize: _kFontSize,
    );

    _infoEventStyle = TextStyle(
      color: _defaultTextStyle.color,
      fontFamily: _kFontFamily,
      fontSize: _kFontSize,
    );

    _space = TextSpan(text: ' ', style: _regularStyle);
  }

  Future<void> _reloadWindowChoices() async {
    final prevWindowFilter = _windowFilter;
    final windows = await WindowManagement.instance.getOpenWindows();

    final indexToTitle = {0: 'All'};
    final indexToWindowKey = <int, String>{0: ''};
    final windowKeyToTitle = <String, String>{};
    final lastScrollPositions = <String, double>{};
    var newSelection = 0;

    var i = 1;
    for (final window in windows) {
      final windowKey = window.windowKey;

      indexToWindowKey[i] = windowKey;
      indexToTitle[i] = window.title;
      windowKeyToTitle[windowKey] = window.title;
      if (prevWindowFilter == windowKey) {
        newSelection = i;
      }

      // Retain last scroll position (if any)
      final prevPosition = _lastScrollPositions[windowKey];
      if (prevPosition != null) {
        lastScrollPositions[windowKey] = prevPosition;
      }
      lastScrollPositions[''] = 0;

      i++;
    }

    setState(() {
      _indexToTitle = indexToTitle;
      _indexToWindowKey = indexToWindowKey;
      _windowKeyToTitle = windowKeyToTitle;
      _lastScrollPositions = lastScrollPositions;
      _windowFilterSelection = newSelection;
      _view.windowKeyFilter = _windowFilter;
    });
  }

  @override
  Widget build(BuildContext context) {
    _prepareStylesAndPieces();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 50, maxHeight: 150),
          child: _buildWindowFilterChips(),
        ),
        Expanded(child: _buildEventList()),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: _reload,
        ),
      ],
    );
  }

  void _onWindowSelection(int index) {
      setState(() {
      _windowFilterSelection = index;
      _view.windowKeyFilter = _windowFilter;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final lastPosition = _lastScrollPositions[_windowFilterChoice];
          _scrollController.jumpTo(lastPosition ?? 0);
        }
      });
    });
  }

  Widget _buildWindowFilterChips() {
    return Row(
      children: [
        const Text('Window'),
        const SizedBox(width: 10),
        Wrap(
          spacing: 5.0,
          children: List<Widget>.generate(_indexToTitle.length, (index) {
            return ChoiceChip(
              label: Text(_indexToTitle[index] ?? ''),
              selected: _windowFilterSelection == index,
              onSelected: (selected) {
                _onWindowSelection(index);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEventList() {
    final includeWindowTitle = _windowFilter == null;
    final defaultTextStyle = DefaultTextStyle.of(context).style;

    return ListView.builder(
      controller: _scrollController,
      itemCount: _view.eventCount,
      itemBuilder: (context, index) => RichText(
        text: _buildEventTextSpan(_view.getItem(index), includeWindowTitle),
      ),
    );
  }

  TextSpan _buildEventTextSpan(EventLogItem item, bool includeWindowTitle) {

    final typeSpan = TextSpan(
      text: '[${item.eventType}]',
      style: _getStyleForEventType(item.eventType, _defaultTextStyle),
    );
    final timeSpan = TextSpan(text: item.eventTime.toString(), style: _regularStyle);
    final messageSpan = TextSpan(text: item.message, style: _regularStyle);

    if (includeWindowTitle) {
      final titleSpan = TextSpan(
        text: _windowKeyToTitle[item.windowKey],
        style: _windowTitleStyle,
      );
      return TextSpan(children: [titleSpan, _space, typeSpan, _space, timeSpan, _space, messageSpan]);
    }

    return TextSpan(children: [typeSpan, _space, timeSpan, _space, messageSpan]);
  }

  TextStyle _getStyleForEventType(String eventType, TextStyle defaultTextStyle) {
    return switch (eventType) {
      'E' => _errorEventStyle,
      'D' => _debugEventStyle,
      'T' || 'W' => _traceEventStyle,
      'FATAL' => _fatalEventStyle,
      _ => _infoEventStyle,
    };
  }
}
