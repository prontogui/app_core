// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:flutter/foundation.dart';

import '../window/window_management.dart';
import 'startup_gate.dart';

/// Orchestrates a chain of [StartupGate]s at app launch.
///
/// Two entry points:
///
///   * [pickInitialGate] — called by the primary engine before
///     [WindowManagement.create]. The result decides whether the
///     primary engine launches as a gate window or as a normal
///     instance window.
///
///   * [advance] — called by a gate window's accept handler after it
///     has persisted its satisfied state (so the gate's [isPending]
///     now returns false). Either opens the next pending gate or
///     restores the instance windows the user had open last session,
///     and arranges for the calling gate window to hide once the
///     next thing is on screen.
///
/// Constructed wherever it's used (primary engine + each gate engine).
/// The gate list is the only state and is cheap to build; gates
/// themselves are stateless wrappers around durable storage, so two
/// engines constructing their own sequence agree on every decision.
class StartupSequence {
  StartupSequence(this._gates, {this.onAllGatesSatisfied});

  final List<StartupGate> _gates;

  /// Hook invoked when the gate chain completes — i.e. no more pending
  /// gates remain. Use for app-wide post-gate setup (e.g. spawning a
  /// hidden Licensing watchdog window) that must not run while a gate
  /// window is on screen, since gate engines are short-lived.
  ///
  /// Fired from [advance] when the chain falls through to
  /// [WindowManagement.restoreInstanceWindows], and from
  /// [firePostGateHookIfNeeded] when the primary engine launches
  /// straight into an instance window without any gate ever running.
  VoidCallback? onAllGatesSatisfied;

  /// Per-engine singleton, set once near the top of `main()`. Gate
  /// views resolve via this rather than having the instance threaded
  /// through `*Info` structs.
  static StartupSequence? _instance;
  static StartupSequence get instance => _instance!;
  static set instance(StartupSequence s) => _instance = s;

  /// Returns the gate the primary engine should launch as, or null if
  /// no gate is pending (in which case the engine becomes a normal
  /// instance window).
  ///
  /// Returns null if any gate already has a live window on screen
  /// from a prior launch — that engine's eventual [advance] call will
  /// pick up the chain on its own, so this engine must not fork it.
  Future<StartupGate?> pickInitialGate() => _findNext();

  /// Advances the chain from the gate window currently calling this
  /// method. Caller must have already persisted its satisfied state
  /// so [StartupGate.isPending] now returns false for it.
  Future<void> advance() async {
    final wm = WindowManagement.instance;
    final currentKey = wm.globalWindowKey;
    final next = await _findNext();

    if (next != null) {
      // Defer hide until the next gate is on screen — same reason
      // the EULA hide is deferred today: avoids a "no visible window"
      // gap on macOS that makes the app appear to terminate.
      wm.onceGlobalWindowOpened(next.globalWindowKey, () {
        wm.hideGlobalWindow(currentKey);
      });
      await wm.openGlobalWindow(next.globalWindowKey);
    } else {
      wm.onceInstanceWindowOpened(() {
        wm.hideGlobalWindow(currentKey);
      });
      onAllGatesSatisfied?.call();
      await wm.restoreInstanceWindows();
    }
  }

  /// Fires [onAllGatesSatisfied] if and only if this engine is the
  /// primary engine launching directly into an instance window — the
  /// no-gates-pending path, where [advance] will never run and so
  /// would never fire the hook. No-op when called from a gate engine
  /// or a reopened instance engine.
  ///
  /// Call from `main()` after [onAllGatesSatisfied] has been
  /// assigned. Decides whether to fire by inspecting
  /// [WindowManagement.instance] — `globalWindowKey.isEmpty` filters
  /// out gate engines, and `isFirstWindowLaunched` filters out
  /// reopened instance engines.
  void firePostGateHookIfNeeded() {
    final wm = WindowManagement.instance;
    if (wm.globalWindowKey.isEmpty && wm.isFirstWindowLaunched) {
      onAllGatesSatisfied?.call();
    }
  }

  Future<StartupGate?> _findNext() async {
    for (final gate in _gates) {
      final v = await WindowSettingsStorage.getStoredVisibility(gate.globalWindowKey);
      // A live engine already owns this gate window — let it run to
      // completion; don't fork the chain.
      if (v != WindowVisibility.none) return null;
      if (await gate.isPending()) return gate;
    }
    return null;
  }
}
