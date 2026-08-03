// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'dart:io' show Platform;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

import 'shutdown_coordinator.dart';
import 'window_message_bus.dart';
import 'window_settings.dart';
import 'window_settings_storage.dart';

export 'shutdown_coordinator.dart';
export 'window_message_bus.dart' show ArgNotifier;
export 'window_settings.dart';
export 'window_settings_storage.dart' show WindowSettingsStorage;

/// Manages opening/closing windows and storing their settings.
///
/// There are two kinds of windows: instance windows and global windows.
///
/// An instance window is the main view of information or document that an
/// application can have several open at the same time. If we're thinking
/// of Microsoft Word then its the document window. Each instance window has
/// its own copy of settings that are saved. When the application is opened,
/// all instance windows that were open last time are reopened again.
///
/// A global window on the other hand is singular in nature and can only be
/// opened once or closed altogether. A global window can be used for things
/// like an Event Log, About window, a settings dialog, and so on. Each
/// global window is identified by a key and all global windows are
/// defined by the application and passed into the constructor for this object.
/// Each kind of global window has its own settings that are saved.
///
/// Window Management Usage Guide
///
/// Flutter desktop apps support only a single window for rendering content.
/// To create additional windows, we use the desktop_multi_window package, which creates
/// each window with a distinct Flutter engine. This means launching a new window is
/// like launching an entirely new app instance.
///
/// Each window operates independently with separate data structures. When we refer to
/// "our window", we mean the window represented by the current Flutter engine. This
/// independence creates challenges when events in one window need to affect others
/// (e.g., when settings change and need to be reflected across all windows).
///
/// Usage:
/// 1. In your main.dart, call WindowManagement.create() to initialize and reopen
///    previously opened windows.
///
/// 2. Examine the returned WindowManagement object to determine what type of window
///    to render based on globalWindowKey and settings properties.
///
/// 3. Use a switch statement or similar logic to render different app widgets based
///    on the window type.
///
/// 4. During app operation, call WindowManagement methods to:
///    - Open new instance windows
///    - Open global windows
///    - Close windows
///    - Handle other window operations in response to menu actions.
///
class WindowManagement extends WindowListener {

  /// The prefix for a lauch argument that creates a new window using default settings.
  static const kNewWindowToken = 'NEW';

  /// The prefix for a launch argument that opens a global window.
  static const kOpenGlobalWindowToken = "OPEN";

  /// Construct from a storage object.
  WindowManagement._ctor(this._storage, this.globalWindowKey, this.isFirstWindowLaunched);

  /// Wires up the conditional handlers WindowManagement owns (windowKey
  /// matching, focus-gating) on top of the bus's typed notifiers, then
  /// installs the channel handler. Pass-through notifiers are exposed to
  /// callers as `notifyXxx` getters that forward to [_bus] directly.
  Future<void> _setUpMessageBus(bool newWindowOpened) async {
    // Wire the shutdown coordinator before `_bus.install()` so the
    // channel handler picks up the registered `onShutdownRequested`
    // hook. Flushing pending storage saves is the first cleanup we
    // register — debounced settings writes (window moves/resizes) must
    // make it to disk before exit.
    ShutdownCoordinator.install(_bus);
    ShutdownCoordinator.instance.addCleanup(() => _storage.save());

    _bus.closeFocusedRequested.addListener(() async {
      if (globalWindowKey.isEmpty && await windowManager.isFocused()) {
        _closeoutWindow();
      }
    });
    _bus.hideWindowRequested.addListener(() {
      if (_bus.hideWindowRequested.arg == _storage.windowKey) {
        _closeoutWindow();
      }
    });
    _bus.showWindowRequested.addListener(() async {
      await _showWindowRequest(_bus.showWindowRequested.arg);
    });
    _bus.messageToFocused.addListener(() async {
      if (globalWindowKey.isEmpty && await windowManager.isFocused()) {
        notifyMessageToOurWindow.notify(_bus.messageToFocused.arg);
      }
    });

    await _bus.install();

    if (newWindowOpened) {
      // This must be done before creating window. Otherwise we get
      // CHANNEL_UNREGISTERED exception since there's a race between
      // notifying the window via a channel and the new window registering
      // the channel to receive method calls.
      await _bus.broadcastWindowOpened(_storage.windowKey);
    }
  }

  /// The single instance of this object.
  static WindowManagement? _instance;

  /// The object used to store settings.
  late WindowSettingsStorage _storage;

  /// All the possible global windows
  static late List<WindowSettings> _allGlobalWindowSettings;

  /// All the possible global window IDs
  static late List<String> _allGlobalWindowKeys;

  /// Cross-engine messaging.
  final WindowMessageBus _bus = WindowMessageBus();

  /// Window status
  bool _isClosed = false;

  /// The settings for our window.
  WindowSettings get settings => _storage.settings;

  /// The key of the global window being created or empty if creating an instance window.
  final String globalWindowKey;

  /// This is the first window launched by the application
  final bool isFirstWindowLaunched;

  // Local notifiers — driven by per-window lifecycle events, not the bus.
  final notifyOurWindowReopened = ArgNotifier<bool>(false);
  final notifyOurWindowClosed = ArgNotifier<bool>(false);
  // The bus exposes `messageToFocused`; we re-publish via this notifier
  // only when our window has focus.
  final notifyMessageToOurWindow = ArgNotifier<String>('');

  // Pass-throughs to bus notifiers, preserving the public WindowManagement API.
  ArgNotifier<bool> get notifySettingsUpdated => _bus.settingsReloaded;
  ArgNotifier<String> get notifyWindowOpened => _bus.windowOpened;
  ArgNotifier<String> get notifyWindowClosed => _bus.windowClosed;
  ArgNotifier<String> get notifyThemeChanged => _bus.themeChanged;
  ArgNotifier<String> get notifyWindowTitleChanged => _bus.windowTitleChanged;
  ArgNotifier<bool> get notifyLicenseInfoUpdated => _bus.licenseInfoUpdated;

  static WindowManagement get instance => _instance!;
  static WindowManagement? get instanceOrNull => _instance;

  static late WindowController _windowController;

  /// True only in the truly primary Flutter engine — the one launched
  /// without args. Distinct from [isFirstWindowLaunched], which is
  /// also true for gate engines that flip it on via `launchWithGlobal`.
  ///
  /// Use this to gate shared-state mutations (kv-store wipes, schema
  /// migrations) so they don't run from sibling engines. Available
  /// after [ensureInitialized] has been called.
  static bool get isPrimaryEngine => _windowController.arguments.isEmpty;

  /// Every global window key the running app supports — i.e. whatever
  /// list was passed to [ensureInitialized]. For an app that layers
  /// additional global windows on top of this package's own set (see
  /// `coreGlobalWindowSettings`), this reflects the combined list, not
  /// just this package's globals. Available after [ensureInitialized].
  static List<String> get allGlobalWindowKeys => _allGlobalWindowKeys;

  /// [maxInstanceWindows] caps how many instance windows the app allows
  /// open at once (globals don't count). Defaults to effectively
  /// unlimited; pass `1` for a single-instance-window edition. See
  /// [WindowSettingsStorage.maxInstanceWindows].
  static Future<void> ensureInitialized(
    List<WindowSettings> allGlobalWindowSettings, {
    int maxInstanceWindows = 20,
  }) async {
    _windowController = await WindowController.fromCurrentEngine();
    _allGlobalWindowSettings = allGlobalWindowSettings;
    _allGlobalWindowKeys = List<String>.generate(allGlobalWindowSettings.length, (i) => allGlobalWindowSettings[i].windowKey);
    WindowSettingsStorage.maxInstanceWindows = maxInstanceWindows;
    if (isPrimaryEngine) {
      await WindowSettingsStorage.doStartupMaintenance(_allGlobalWindowKeys);
    }
  }

  /// Whether the app allows spawning more than one instance window.
  /// Drives whether menu surfaces (`WindowMenuBar`'s "New Window" item)
  /// should offer the capability at all.
  static bool get allowsMultipleInstanceWindows => WindowSettingsStorage.maxInstanceWindows > 1;

  /// Creates the singleton [WindowManagement] for the current Flutter
  /// engine. There can only be one call per engine; a second call throws.
  ///
  /// What the call does depends on the launch arguments of the current
  /// window (read from `WindowController.fromCurrentEngine().arguments`):
  ///
  ///   * empty       — primary launch. Runs storage maintenance, then
  ///                   either reopens previously-saved instance windows
  ///                   or creates a fresh primary instance window.
  ///   * `NEW`       — a fresh instance window spawned by another engine.
  ///                   This isolate picks its own windowKey from
  ///                   `windowController.windowId`.
  ///   * `OPEN<K>,<v>` — opens the global window keyed `<K>`, with
  ///                   `<v>` ∈ {true, false} controlling initial visibility.
  ///   * `<windowKey>` — reopens an existing instance window by its
  ///                   stored windowKey.
  ///
  /// [allGlobalWindowSettings] declares every global window the app
  /// supports — used to look up settings for the `OPEN<K>` path and to
  /// distinguish global keys from instance keys throughout.
  ///
  /// [launchWithGlobal], when supplied, overrides the primary engine's empty
  /// launch arg with `OPEN<launchGlobal>,true`, so the primary window
  /// comes up as the named global instead of an instance window. Useful
  /// for forcing a particular flow (e.g. EULA, Licensing) on first run
  /// or in debug. Throws if [launchWithGlobal] isn't one of the keys in
  /// [allGlobalWindowSettings].
  static Future<WindowManagement> create({String? launchWithGlobal}) async {
  
    if (_instance != null) {
      throw Exception('Cannot create WindowManagement more than once. It is singleton.');
    }

    // Initialize the window manager
    await windowManager.ensureInitialized();

    // Get the argument used to launch window. The format of the argument dictates what kind
    // of window is being opened.
    //
    // The format of arg is one of the following:
    // <empty>      : our window is the first one launched by the application
    // NEW          : opening a fresh instance window; this isolate picks its own windowKey
    // OPEN<GWKEY>,<visible> : opening a global window
    // <windowKey>  : re-opening an instance window by its windowKey
    String arg = _windowController.arguments;

    bool isFirstWindowLaunched = arg.isEmpty;

    if (launchWithGlobal != null) {
      if (!_allGlobalWindowKeys.contains(launchWithGlobal)) {
        throw Exception('Programming error - launchGlobal argument value ("$launchWithGlobal") is not a valid global window key');
      }
      arg = 'OPEN$launchWithGlobal,true';
      isFirstWindowLaunched = true;
    }

    late WindowSettingsStorage storage;
    String globalWindowKey = '';
    bool visibleAtLaunch = true;
    bool newWindowOpened = false;

    // Are we the first window launched of application?
    if (arg.isEmpty) {

      // Get list of window keys that are saved in settings
      var savedWindowKeys = await WindowSettingsStorage.listInstanceWindows(_allGlobalWindowKeys);

      if (savedWindowKeys.isEmpty) {
        // Create storage from default and use the unique windowKey we were given.
        storage = await WindowSettingsStorage.create(_windowController.windowId, _allGlobalWindowKeys);
        await storage.save();
      } else {
        // Adopt the first saved window's settings under our new windowKey,
        // then drop the old row so we don't leave a stranded duplicate.
        final oldWindowKey = savedWindowKeys.first;
        storage = await WindowSettingsStorage.open(oldWindowKey, _allGlobalWindowKeys);
        storage.settings.windowKey = _windowController.windowId;
        await storage.save();
        await WindowSettingsStorage.remove(oldWindowKey);

        // Reopen every additional window
        for (final savedWindowKey in savedWindowKeys.getRange(1, savedWindowKeys.length)) {
          await _reopenWindow(savedWindowKey);
        }
      }

    // Are we a new instance window spawned by another window?
    } else if (arg.startsWith(kNewWindowToken)) {
      // Pick our own windowKey from windowController.windowId — the
      // orchestrator doesn't know it ahead of time.
      storage = await WindowSettingsStorage.create(_windowController.windowId, _allGlobalWindowKeys);
      await storage.save();
      newWindowOpened = true;

    // Are we a global window being opened?
    } else if (arg.startsWith(kOpenGlobalWindowToken)) {

      // Parse the global window arguments
      final launchArgs = arg.substring(kOpenGlobalWindowToken.length).split(',');
      globalWindowKey = launchArgs[0];
      visibleAtLaunch = launchArgs[1] == 'true';

      var globalWindowSettings = _allGlobalWindowSettings.firstWhereOrNull((gws) => gws.windowKey == globalWindowKey);
      if (globalWindowSettings == null) {
        throw Exception('Programming error - global window key not defined.');
      }

      storage = await WindowSettingsStorage.createFromSettings(globalWindowSettings, _allGlobalWindowKeys);
      // Force the write when the template wants resets — the clone
      // itself is clean, but for `resetOnOpen` globals we explicitly
      // bring kv into agreement with the template here.
      await storage.save(force: globalWindowSettings.resetOnOpen);

    // Otherwise, must be an instance window being reopened
    } else {
      storage = await WindowSettingsStorage.open(arg, _allGlobalWindowKeys);
    }

    final wm = WindowManagement._ctor(storage, globalWindowKey, isFirstWindowLaunched);
    _instance = wm;

    await wm._setUpMessageBus(newWindowOpened);

    // Listen for when window is resize, moved, closed, etc.
    windowManager.addListener(wm);

    final settings = storage.settings;

    // Configure and show our window according to its settings
    WindowOptions windowOptions = WindowOptions(
      size: settings.size,
      center: settings.displayMode == WindowDisplayMode.centered,
      skipTaskbar: false,
      //titleBarStyle: TitleBarStyle.normal,
      title: settings.title,
    );

    // Present our window
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      // Explicitly bring the native window's geometry into agreement
      // with our settings before any reveal happens. The native window
      // was created hidden (via WindowConfiguration.hiddenAtLaunch);
      // we apply size/position here while it's still hidden, then
      // reveal below so the user never sees the OS-default geometry.
      await windowManager.setSize(settings.size);
      if (settings.displayMode == WindowDisplayMode.centered) {
        await windowManager.center();
      } else {
        await windowManager.setPosition(settings.position);
      }
      // Override the automatic closing of windows when close button clicked
      await windowManager.setPreventClose(true);
      if (visibleAtLaunch) {
        // Two shows because two plugins manage the same OS window
        // through different APIs and don't share state:
        //   * `_windowController.show()` un-hides at the
        //     `desktop_multi_window` level (which set hiddenAtLaunch).
        //   * `windowManager.show()` ensures `window_manager`'s state
        //     is "visible" so subsequent calls (focus, set*) and
        //     listener events line up.
        await windowManager.show();
        await _windowController.show();
        await windowManager.focus();

        settings.visibility = WindowVisibility.visible;

        // Tell other engines this engine's window is now on screen.
        // Instance and global windows fire on separate channels so
        // listeners can wait for the kind they care about — e.g. the
        // EULA accept handler waits for the next instance window
        // before hiding itself, while StartupSequence.advance waits
        // for a sibling gate window.
        if (wm.globalWindowKey.isEmpty) {
          await wm._bus.broadcastInstanceWindowOpened(wm._storage.windowKey);
        } else {
          await wm._bus.broadcastGlobalWindowOpened(wm._storage.windowKey);
        }
      } else {
        settings.visibility = WindowVisibility.hidden;
      }
      await storage.save();
    });

    return wm;
  }

  /// Re-opens a window with key [windowKey] that is saved to settings.
  ///
  /// The native window is created hidden; the spawned engine reveals
  /// itself from its `waitUntilReadyToShow` callback after applying
  /// size/position, so the user never sees the window briefly at
  /// OS-default geometry. See [create]'s show block for the dual
  /// `_windowController.show()` + `windowManager.show()` that handles
  /// both `desktop_multi_window`'s and `window_manager`'s notion of
  /// visibility.
  static Future<void> _reopenWindow(String windowKey) async {
    await WindowController.create(
      WindowConfiguration(
        hiddenAtLaunch: true,
        arguments: windowKey,
      ),
    );
  }

  /// Show ourselves if [windowKey] addresses us. Used for both
  /// repurposing a hidden instance window and re-showing a global
  /// window that's already alive in this isolate.
  ///
  /// Reset semantics:
  ///   * Instance window — always rebuild [_storage] from kv defaults
  ///     so the user gets a fresh window rather than the prior
  ///     session's host/port/size/position.
  ///   * Global window — rebuild from the template only when the
  ///     template's `resetOnOpen` flag is true. Otherwise keep the
  ///     existing [_storage] so the user's customizations carry
  ///     across hide/show cycles.
  Future<void> _showWindowRequest(String windowKey) async {
    if (windowKey != _storage.windowKey) {
      return;
    }
    _isClosed = false;

    bool wasReset = false;
    if (globalWindowKey.isEmpty) {
      _storage = await WindowSettingsStorage.create(_storage.windowKey, _allGlobalWindowKeys);
      wasReset = true;
    } else {
      final template = _allGlobalWindowSettings.firstWhereOrNull(
        (s) => s.windowKey == _storage.windowKey,
      );
      if (template != null && template.resetOnOpen) {
        _storage = await WindowSettingsStorage.createFromSettings(template, _allGlobalWindowKeys);
        wasReset = true;
      }
    }

    _storage.settings.visibility = WindowVisibility.visible;
    await _storage.save();

    if (wasReset) {
      // Bring the native window's geometry into agreement with the
      // freshly applied settings. Without this, show() would display
      // the window at whatever size/position the OS still has it at —
      // stale for an instance-window repurpose and for a resetOnOpen
      // global that was previously moved/resized.
      await windowManager.setSize(_storage.settings.size);
      if (_storage.settings.displayMode == WindowDisplayMode.centered) {
        await windowManager.center();
      } else {
        await windowManager.setPosition(_storage.settings.position);
      }
    }

    await windowManager.setTitle(_storage.settings.title);
    windowManager.show();
    notifyOurWindowReopened.notify(true);
    await _bus.broadcastWindowOpened(_storage.windowKey);
  }

  /// Save any changes to window settings.
  Future<void> saveSettings() async {
    await _storage.save();
  }

  /// Gets information about all the open instance windows.
  Future<List<WindowDetails>> getOpenWindows() async {
    return WindowSettingsStorage.listInstanceWindowDetails(_allGlobalWindowKeys);
  }

  /// Reopens every previously-saved instance window in its own fresh
  /// isolate. If no instance windows are saved, opens a single fresh
  /// instance window via [newInstanceWindow] instead.
  ///
  /// Use this when transitioning out of a global-window-only launch
  /// flow (e.g. after the user accepts the EULA and the primary engine
  /// is currently rendering the EULA) so the user lands back in the
  /// instance windows they had open.
  Future<void> restoreInstanceWindows() async {
    final saved = await WindowSettingsStorage.listInstanceWindows(_allGlobalWindowKeys);
    if (saved.isEmpty) {
      await newInstanceWindow();
      return;
    }
    for (final key in saved) {
      await _reopenWindow(key);
    }
  }

  /// Opens a new instance window. Returns true if a window was opened
  /// (either a brand-new one or a hidden one re-shown), false if the
  /// max-instance-window cap is reached.
  Future<bool> newInstanceWindow() async {
    // If there's a hidden instance window, repurpose it instead of
    // spawning a new isolate.
    final hiddenKey = await WindowSettingsStorage.findHiddenInstanceWindow(_allGlobalWindowKeys);
    if (hiddenKey != null) {
      _bus.broadcastShowWindow(hiddenKey);
      return true;
    }

    if (!await WindowSettingsStorage.canSpawnInstanceWindow(_allGlobalWindowKeys)) {
      return false;
    }

    // Spawn a fresh window. The new isolate picks its own windowKey
    // (from windowController.windowId) and writes its row on startup.
    await WindowController.create(
      WindowConfiguration(
        hiddenAtLaunch: true,
        arguments: kNewWindowToken,
      ),
    );
    return true;
  }

  /// Opens a global window identified by [globalWindowKey]. This key must correspond to the
  /// global window keys defined by the application. If the window is already open then it
  /// brings the window forward and into focus.
  Future<void> openGlobalWindow(String globalWindowKey, {bool visableAtLaunch = true}) async {

    final visibility = await WindowSettingsStorage.getStoredVisibility(globalWindowKey);
    // If a live isolate already owns this global window, just notify it.
    if (visibility != WindowVisibility.none) {
      _bus.broadcastShowWindow(globalWindowKey);
      return;
    }

    // Create the new window and let its isolate do the rest
    await WindowController.create(
      WindowConfiguration(
        hiddenAtLaunch: true,
        arguments: '$kOpenGlobalWindowToken$globalWindowKey,$visableAtLaunch',
      ),
    );
  }

  /// Hides a global window identified by [globalWindowKey].  This key must correspond to the
  /// global window keys defined by the application.
  Future<void> hideGlobalWindow(String globalWindowKey) async {
    final visibility = await WindowSettingsStorage.getStoredVisibility(globalWindowKey);
    if (visibility == WindowVisibility.visible) {
      _bus.broadcastHideWindow(globalWindowKey);
      return;
    }
  }

  /// Closes the window that currently has focus. This is ignored if a
  /// global window has focus.
  Future<void> closeFocusedInstanceWindow() => _bus.broadcastCloseFocused();

  /// Sends a message to the instance window that currently has focus. This is
  /// ignored if a global window has focus.
  Future<void> sendMessageToFocusedInstanceWindow(String message) => _bus.broadcastMessageToFocused(message);

  /// Broadcasts a theme change to all windows.
  Future<void> broadcastThemeChange(String theme) => _bus.broadcastThemeChange(theme);

  /// Broadcasts a window title change to all windows.
  Future<void> broadcastTitleChange(String windowKey) => _bus.broadcastTitleChange(windowKey);

  /// Broadcasts that license info has been updated to all windows.
  Future<void> broadcastLicenseInfoUpdated() => _bus.broadcastLicenseInfoUpdated();

  /// Registers a one-shot listener that fires the next time any
  /// instance window reports it is open and on screen, then
  /// auto-detaches. Used by the EULA gate to defer hiding itself
  /// until at least one instance window is visible — closing the
  /// EULA before that lands would briefly leave the app with no
  /// visible window, which on macOS makes the app appear to terminate.
  void onceInstanceWindowOpened(VoidCallback callback) {
    late VoidCallback listener;
    listener = () {
      _bus.instanceWindowOpened.removeListener(listener);
      callback();
    };
    _bus.instanceWindowOpened.addListener(listener);
  }

  /// Registers a one-shot listener that fires the next time the
  /// global window keyed [globalWindowKey] reports it is open and on
  /// screen, then auto-detaches. Mirrors [onceInstanceWindowOpened]
  /// for the gate-to-gate handoff in [StartupSequence.advance], which
  /// hides the calling gate only once its successor is visible.
  void onceGlobalWindowOpened(String globalWindowKey, VoidCallback callback) {
    late VoidCallback listener;
    listener = () {
      if (_bus.globalWindowOpened.arg != globalWindowKey) return;
      _bus.globalWindowOpened.removeListener(listener);
      callback();
    };
    _bus.globalWindowOpened.addListener(listener);
  }

  Future<void> _closeoutWindow() async {

    if (_isClosed) {
      return;
    }
    _isClosed = true;

    final windowKey = _storage.settings.windowKey;

    _storage.settings.visibility = WindowVisibility.hidden;
    await _storage.save();

    // Allow listeners to perform any clean up
    notifyOurWindowClosed.notify(true);
    await _bus.broadcastWindowClosed(windowKey);

    await windowManager.hide();

    // Windows-only: Flutter desktop doesn't auto-quit when the last
    // window closes — the process keeps running with all engines
    // alive. If we just hid the last visible window anywhere in the
    // process, kick off clean shutdown via the coordinator.
    if (Platform.isWindows) {
      final visible = await WindowSettingsStorage.countVisibleWindows();
      if (visible == 0) {
        await ShutdownCoordinator.instance.requestShutdown();
      }
    }
  }

  /// Handler when our window is explicitly closed (not due to quitting app)
  @override
  void onWindowClose() async {
    await _closeoutWindow();
  }

  /// Handler when window has been moved. Note: these events can happen several times
  /// in a sequence as the user moves the window to a new location. In other words,
  /// the handler is not simply called once after the user moves the window.
  @override
  void onWindowMoved() async {
    _storage.settings.position = await windowManager.getPosition();
    _storage.settings.displayMode = WindowDisplayMode.normal;

    // Delay the saving of settings since we might get several of these events in a
    // sequence.
    await _storage.save(delayed: true);
    super.onWindowMove();
  }

  /// Handler when window has been resized.
  @override
  void onWindowResized() async {
    _storage.settings.size = await windowManager.getSize();
    _storage.settings.displayMode = WindowDisplayMode.normal;
    await _storage.save();
    super.onWindowResized();
  }
}
