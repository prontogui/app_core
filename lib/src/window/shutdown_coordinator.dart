// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:dartlib/log.dart';

import 'window_message_bus.dart';

/// Coordinates app-wide clean shutdown across all Flutter engines in
/// the process.
///
/// Why this exists
/// ---------------
/// On Windows, Flutter desktop doesn't auto-quit when the last window
/// closes — the process keeps running. With `desktop_multi_window`
/// every window is a Flutter engine in this same process, so any one
/// engine can call `exit(0)` to terminate them all. The job of this
/// class is to make sure each engine has flushed its work *before*
/// that exit happens.
///
/// One coordinator per engine is created in
/// `WindowManagement._setUpMessageBus` via [install]. Each engine
/// registers its own cleanup callbacks ([addCleanup]); when shutdown
/// is requested (locally via [requestShutdown] or remotely via the
/// bus), every engine runs its callbacks once and the process exits.
///
/// Trigger logic
/// -------------
/// The trigger lives in `WindowManagement._closeoutWindow`: after a
/// window hides itself, if no visible windows remain anywhere in the
/// process, that engine calls [requestShutdown]. Either kind of
/// window — instance or global — counts; the user has effectively
/// dismissed the app.
class ShutdownCoordinator {
  ShutdownCoordinator._(this._bus);

  /// Hard cap on shutdown so a hung resource can't leave a zombie
  /// process. If cleanup hasn't completed by then, [requestShutdown]
  /// exits anyway.
  static const _kShutdownTimeout = Duration(seconds: 5);

  static ShutdownCoordinator? _instance;
  static ShutdownCoordinator get instance => _instance!;

  final WindowMessageBus _bus;
  final List<Future<void> Function()> _cleanups = [];
  bool _shuttingDown = false;
  bool _localCleanupRan = false;

  /// Wires this engine's coordinator to [bus]. Must be called before
  /// [WindowMessageBus.install] so the channel handler picks up
  /// `onShutdownRequested`. Idempotent within an engine.
  static void install(WindowMessageBus bus) {
    if (_instance != null) return;
    final coord = ShutdownCoordinator._(bus);
    _instance = coord;
    bus.onShutdownRequested = coord._runLocalCleanup;
  }

  /// Register an async cleanup callback to run during shutdown.
  /// Callbacks fire in registration order. They should be idempotent
  /// — `notifyOurWindowClosed`-driven cleanup may already have
  /// fired for the engine whose window the user X'd.
  void addCleanup(Future<void> Function() cleanup) {
    _cleanups.add(cleanup);
  }

  /// Initiate clean shutdown. Tells siblings to flush, runs local
  /// cleanup, then exits the process. Re-entry is a no-op so
  /// concurrent triggers (e.g. two engines simultaneously detecting
  /// "no visible windows") collapse safely.
  Future<void> requestShutdown() async {
    if (_shuttingDown) return;
    _shuttingDown = true;

    bootLogger.i('Clean shutdown requested');

    try {
      await _runShutdownPipeline().timeout(_kShutdownTimeout);
    } catch (e) {
      bootLogger.w('shutdown cleanup did not complete cleanly: $e');
    }

    bootLogger.i('Exiting process');
    exit(0);
  }

  Future<void> _runShutdownPipeline() async {
    // Tell siblings first. Their dispatch handler awaits their own
    // local cleanup, so this future only resolves once they're flushed.
    // `WindowController.getAll()` may include self; the
    // `_localCleanupRan` guard makes the second call a no-op.
    await _bus.broadcastShutdownRequested();
    await _runLocalCleanup();
  }

  Future<void> _runLocalCleanup() async {
    if (_localCleanupRan) return;
    _localCleanupRan = true;
    for (final cb in _cleanups) {
      try {
        await cb();
      } catch (e) {
        bootLogger.w('shutdown cleanup callback failed: $e');
      }
    }
  }
}
