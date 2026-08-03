// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kDebugMode, TargetPlatform;
import 'package:flutter/material.dart';
import 'debug_config.dart';
import 'global_windows.dart';
import 'waiting_for_server_view.dart';
import 'background_view.dart';
import 'top_level_coordinator.dart';
import 'app_settings.dart';
import 'window/window_management.dart';
import 'window/window_menu_bar.dart';

const _kConfigureWindowMessage = 'configure_window';

/// Whether to render the Flutter [WindowMenuBar]. Always on for Windows
/// and Linux; on macOS only when the debug override is enabled, since
/// macOS ships with a native menu bar.
bool get _showFlutterMenuBar {
  if (defaultTargetPlatform != TargetPlatform.macOS) return true;
  return kDebugMode && DebugConfig.showFlutterMenuOnMacOS;
}

/// Whether to show Flutter's performance overlay on every `MaterialApp`,
/// gated on debug builds.
bool get _showPerformanceOverlay =>
    kDebugMode && DebugConfig.showPerformanceOverlay;

/// The user's stored theme mode, optionally overridden by
/// [DebugConfig.forceTheme] in debug builds.
ThemeMode _effectiveThemeMode() {
  if (kDebugMode) {
    switch (DebugConfig.forceTheme) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
    }
  }
  return AppSettings.instance.themeMode;
}

class App extends StatefulWidget {
  // Build for the local scenario, i.e., a model is hosted locally.
  const App.local({super.key}) : devWidget = null, topBanner = null, _builderType = _BuilderType.local;

  // Build for the remote scenario, i.e., a model is served by a remote process
  // or server program. [topBanner], when non-null, is rendered above the
  // main content — e.g. an app that layers licensing on top of this
  // package can supply its own "no license installed" banner here without
  // this widget needing to know licensing exists. The caller owns
  // rebuilding this widget (and thus [topBanner]) whenever the banner's
  // content should change.
  const App.remote({super.key, this.topBanner}) : devWidget = null, _builderType = _BuilderType.remote;

  // Build for the alternate development scenario, i.e., we are using the App
  // to develop or debug a new embodiment.
  const App.altdev1({super.key}) : devWidget = null, topBanner = null, _builderType = _BuilderType.altdev1;

  // Build for the alternate development scenario, i.e., we are using the App
  // to develop or debug a new embodiment.
  const App.altdev2({super.key, required this.devWidget}) : topBanner = null, _builderType = _BuilderType.altdev2;

  // For alt-dev 2, the widget we are developing or debugging.
  final Widget? devWidget;

  // Optional banner rendered above the main content in the remote scenario.
  final Widget? topBanner;

  // The type of builder to use.
  final _BuilderType _builderType;

  @override
  State<App> createState() => _AppState();
}

enum _BuilderType { local, remote, altdev1, altdev2 }

class _AppState extends State<App> {
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    switch (widget._builderType) {
      case _BuilderType.local:
        return _buildForLocal(context);
      case _BuilderType.remote:
        return _buildForRemote(context);
      case _BuilderType.altdev1:
        return _buildForAltdev1(context);
      case _BuilderType.altdev2:
        return _buildForAltdev2(context);
    }
  }

  // This widget is the root of your application.
  Widget _buildForLocal(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: _showPerformanceOverlay,
      title: 'ProntoGUI™ Editor',
      theme: AppSettings.instance.lightTheme,
      darkTheme: AppSettings.instance.darkTheme,
      themeMode: _effectiveThemeMode(),
      home: const TopLevelCoordinator(
        backgroundView: BackgroundView(),
      ),
    );
  }

  // This widget is the root of your application.
  Widget _buildForRemote(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: _showPerformanceOverlay,
        title: 'ProntoGUI™',
        theme: AppSettings.instance.lightTheme,
        darkTheme: AppSettings.instance.darkTheme,
        themeMode: _effectiveThemeMode(),
        home: () {
          final body = Column(
            children: [
              if (widget.topBanner != null) widget.topBanner!,
              const Expanded(
                child: WaitingForServerView(
                  operatingView: TopLevelCoordinator(
                    backgroundView: BackgroundView(),
                  ),
                ),
              ),
            ],
          );
          if (!_showFlutterMenuBar) return body;
          return WindowMenuBar(
            logWindowKey: kLogWindowKey,
            settingsWindowKey: kSettingsWindowKey,
            aboutWindowKey: kAboutWindowKey,
            configureWindowMessage: _kConfigureWindowMessage,
            child: body,
          );
        }());
  }

  // This widget is the root of your application.
  Widget _buildForAltdev1(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      showPerformanceOverlay: _showPerformanceOverlay,
      title: '<Alt Dev 1>',
      theme: AppSettings.instance.lightTheme,
      darkTheme: AppSettings.instance.darkTheme,
      themeMode: _effectiveThemeMode(),
      home: const BackgroundView(),
    );
  }

  Widget _buildForAltdev2(BuildContext context) {
    buildDevContainer(Widget devWidget) {
      return Expanded(
          child: Container(
              color: Colors.blueGrey,
              child: Center(
//                  child: SizedBox(width: 400, height: 50, child: devWidget))));
                  child: SizedBox(width: 400, child: devWidget))));
    }

    return MaterialApp(
      debugShowCheckedModeBanner: true,
      showPerformanceOverlay: _showPerformanceOverlay,
      title: '<Alt Dev 2>',
      theme: AppSettings.instance.lightTheme,
      darkTheme: AppSettings.instance.darkTheme,
      themeMode: _effectiveThemeMode(),
      home: Scaffold(body: buildDevContainer(widget.devWidget!)),
    );
  }
}
