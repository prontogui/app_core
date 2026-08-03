// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';

/// Cross-engine message bus for `desktop_multi_window` apps.
///
/// Wraps the underlying `WindowController.invokeMethod` channel so callers
/// don't have to think about method names or argument tuples. One bus per
/// Flutter engine; a single dispatch switch lives here, and consumers
/// subscribe via the typed [ArgNotifier]s exposed below.
///
/// The send/receive pair for each message is named consistently:
/// `broadcastXxx(...)` to send, `xxx` (a notifier) to subscribe.
class WindowMessageBus {

  WindowMessageBus();

  /// The platform-channel method that carries every cross-window message.
  /// The arguments are `[methodName, payload]`; we dispatch on `methodName`.
  static const _kNotifyAllMethod = 'notify_all';

  static const _kReloadSettingsMethod = 'reload_settings';
  static const _kWindowOpenedMethod = 'window_opened';
  static const _kWindowClosedMethod = 'window_closed';
  static const _kCloseFocusedWindowMethod = 'close_focused_window';
  static const _kHideWindowRequestMethod = 'hide_window';
  static const _kShowWindowRequestMethod = 'show_window';
  static const _kMessageToFocusedWindowMethod = 'message_focused_window';
  static const _kThemeChangedMethod = 'theme_changed';
  static const _kWindowTitleChangedMethod = 'window_title_changed';
  static const _kLicenseInfoUpdatedMethod = 'license_info_updated';
  static const _kInstanceWindowOpenedMethod = 'instance_window_opened';
  static const _kGlobalWindowOpenedMethod = 'global_window_opened';
  static const _kShutdownRequestedMethod = 'shutdown_requested';

  // ---------------------------------------------------------------------------
  // Receive: typed notifiers, one per message kind. Listeners are called
  // every time the corresponding broadcast arrives — including when the
  // payload hasn't changed since the previous one (this is what makes them
  // [ArgNotifier]s rather than [ValueNotifier]s).
  // ---------------------------------------------------------------------------

  final settingsReloaded = ArgNotifier<bool>(false);
  final windowOpened = ArgNotifier<String>('');
  final windowClosed = ArgNotifier<String>('');
  final closeFocusedRequested = ArgNotifier<bool>(false);
  final hideWindowRequested = ArgNotifier<String>('');
  final showWindowRequested = ArgNotifier<String>('');
  final messageToFocused = ArgNotifier<String>('');
  final themeChanged = ArgNotifier<String>('');
  final windowTitleChanged = ArgNotifier<String>('');
  final licenseInfoUpdated = ArgNotifier<bool>(false);
  final instanceWindowOpened = ArgNotifier<String>('');
  final globalWindowOpened = ArgNotifier<String>('');

  /// Single async hook for the shutdown message — distinct from the
  /// notifiers above because the broadcaster's `invokeMethod` future
  /// must wait for cleanup to finish before the process exits. A
  /// listener-list pattern would let `notifyListeners` return before
  /// async listeners completed; this callback is awaited directly in
  /// `_dispatch`. The [ShutdownCoordinator] is the single owner.
  Future<void> Function()? onShutdownRequested;

  /// Installs the receive handler on the current Flutter engine. Subscribers
  /// should be attached to the notifiers above before this returns, so no
  /// early-arriving messages are dropped.
  Future<void> install() async {
    final wc = await WindowController.fromCurrentEngine();
    wc.setWindowMethodHandler((call) async {
      if (call.method != _kNotifyAllMethod) return;
      final args = call.arguments as List<Object?>;
      final method = args[0] as String;
      final payload = args[1] as String;
      await _dispatch(method, payload);
    });
  }

  Future<void> _dispatch(String method, String payload) async {
    switch (method) {
      case _kReloadSettingsMethod:
        settingsReloaded.notify(false);
      case _kWindowOpenedMethod:
        windowOpened.notify(payload);
      case _kWindowClosedMethod:
        windowClosed.notify(payload);
      case _kCloseFocusedWindowMethod:
        closeFocusedRequested.notify(true);
      case _kHideWindowRequestMethod:
        hideWindowRequested.notify(payload);
      case _kShowWindowRequestMethod:
        showWindowRequested.notify(payload);
      case _kMessageToFocusedWindowMethod:
        messageToFocused.notify(payload);
      case _kThemeChangedMethod:
        themeChanged.notify(payload);
      case _kWindowTitleChangedMethod:
        windowTitleChanged.notify(payload);
      case _kLicenseInfoUpdatedMethod:
        licenseInfoUpdated.notify(true);
      case _kInstanceWindowOpenedMethod:
        instanceWindowOpened.notify(payload);
      case _kGlobalWindowOpenedMethod:
        globalWindowOpened.notify(payload);
      case _kShutdownRequestedMethod:
        // Awaited so the broadcasting engine's `invokeMethod` doesn't
        // return until this engine has flushed.
        await onShutdownRequested?.call();
    }
  }

  // ---------------------------------------------------------------------------
  // Send: one method per message kind, all routing through `_send`.
  // ---------------------------------------------------------------------------

  Future<void> _send(String method, String payload) async {
    final windows = await WindowController.getAll();
    for (final wc in windows) {
      // WindowController.getAll() isn't always accurate after windows are
      // closed; ignore any exception we might get.
      try {
        await wc.invokeMethod(_kNotifyAllMethod, <String>[method, payload]);
      } catch (_) {}
    }
  }

  Future<void> broadcastSettingsReload() => _send(_kReloadSettingsMethod, '');
  Future<void> broadcastWindowOpened(String windowKey) => _send(_kWindowOpenedMethod, windowKey);
  Future<void> broadcastWindowClosed(String windowKey) => _send(_kWindowClosedMethod, windowKey);
  Future<void> broadcastCloseFocused() => _send(_kCloseFocusedWindowMethod, '');
  Future<void> broadcastHideWindow(String windowKey) => _send(_kHideWindowRequestMethod, windowKey);
  Future<void> broadcastShowWindow(String windowKey) => _send(_kShowWindowRequestMethod, windowKey);
  Future<void> broadcastMessageToFocused(String message) => _send(_kMessageToFocusedWindowMethod, message);
  Future<void> broadcastThemeChange(String theme) => _send(_kThemeChangedMethod, theme);
  Future<void> broadcastTitleChange(String windowKey) => _send(_kWindowTitleChangedMethod, windowKey);
  Future<void> broadcastLicenseInfoUpdated() => _send(_kLicenseInfoUpdatedMethod, '');
  Future<void> broadcastInstanceWindowOpened(String windowKey) => _send(_kInstanceWindowOpenedMethod, windowKey);
  Future<void> broadcastGlobalWindowOpened(String windowKey) => _send(_kGlobalWindowOpenedMethod, windowKey);
  Future<void> broadcastShutdownRequested() => _send(_kShutdownRequestedMethod, '');
}

/// Notifies listeners with an argument. Unlike `ValueNotifier`, this always
/// calls the listeners regardless of whether the argument has changed.
class ArgNotifier<T> extends ChangeNotifier {
  ArgNotifier(this._arg);

  T _arg;
  T get arg => _arg;

  void notify(T arg) {
    _arg = arg;
    notifyListeners();
  }
}
