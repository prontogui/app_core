// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dartlib/log.dart';
import 'src/debug_config.dart';
import 'src/window/window_management.dart';
import 'src/app_settings.dart';
import 'src/eula_acceptance.dart';
import 'src/global_windows.dart';
import 'src/startup/debug_startup.dart';
import 'src/startup/global_window_dispatcher.dart';
import 'src/startup/instance_window_app.dart';
import 'src/startup/logging_setup.dart';
import 'src/startup/startup_gate.dart';
import 'src/startup/startup_sequence.dart';

/// Application entry point for the free/open-source ProntoGUI Core app.
///
/// This is the single-instance-window edition: it caps
/// `WindowManagement`'s instance-window count at 1 (see the
/// `maxInstanceWindows` argument to `WindowManagement.ensureInitialized`
/// below), but otherwise supports the full set of global windows
/// (EULA/About/Settings/Event Log/Licensing Credits) via
/// `desktop_multi_window`, exactly like any other multi-engine desktop
/// Flutter app. There's no licensing here — this is the entire free
/// product.
///
/// The proprietary `app` repo mirrors this file, raising the instance
/// window cap, adding its own licensing startup steps, and registering
/// its own additional global window (Licensing) alongside this
/// package's globals.
///
/// Pre-flight gates (currently just the EULA, with room for future
/// gates like "Updates Available") are sequenced by [StartupSequence];
/// see `src/startup/startup_sequence.dart` for the chain semantics
/// and `src/startup/startup_gate.dart` for the gate interface.
///
/// Window infrastructure — settings storage, cross-engine messaging,
/// reopening saved windows — lives in `src/window/window_management.dart`.
/// The set of global windows this package supports is defined in
/// `src/global_windows.dart`.
Future<void> main(List<String> args) async {

  // Required before any other Flutter API call (PackageInfo,
  // WindowManagement, runApp).
  WidgetsFlutterBinding.ensureInitialized();

  // Hand WM the list of global windows this app supports, and cap
  // instance windows at 1 — the free/personal edition's defining
  // constraint. See `src/global_windows.dart`.
  await WindowManagement.ensureInitialized(
    coreGlobalWindowSettings,
    maxInstanceWindows: 1,
  );

  // Apply debug-only side effects of [DebugConfig] (paint overlays,
  // optional kv-store wipe). No-op in release. See
  // `src/startup/debug_startup.dart`.
  await applyDebugStartup();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  bootLogger.i('Welcome to ProntoGUI™ Core version ${packageInfo.version}');

  // === Startup-gate dependencies — anything _buildStartupGates needs ===
  await AppSettings.create();
  final eulaAcceptance = await EulaAcceptance.create();
  // =====================================================================

  // Per-engine singleton. Every engine constructs the same gate list
  // and agrees on each gate's pending state via storage, so the
  // primary engine's `pickInitialGate` and a gate engine's `advance`
  // always reach the same conclusion.
  StartupSequence.instance = StartupSequence(_buildStartupGates(eulaAcceptance));

  // If a gate is pending, the primary engine launches as that gate
  // window (`launchWithGlobal` overrides the empty-arg path inside
  // `WindowManagement.create`). Otherwise the engine takes the
  // normal instance-window path.
  final initialGate = await StartupSequence.instance.pickInitialGate();
  final windowManagement = await WindowManagement.create(
    launchWithGlobal: initialGate?.globalWindowKey,
  );

  _doFirstWindowMaintenance(windowManagement);

  // Fires `onAllGatesSatisfied` only when this engine took the
  // direct (no-gate) path. Gate engines fire it via `advance` from
  // their accept handler; reopened instance engines never fire it.
  StartupSequence.instance.firePostGateHookIfNeeded();

  // File-backed logging grouped by this engine's window key, plus
  // log-level resolution from cmd-line args + build mode. See
  // `src/startup/logging_setup.dart`.
  await configureLogging(args, windowManagement.settings.windowKey);

  // Terminal dispatch. Global window first; if not a global, the
  // engine renders the document-style instance window UI.
  final didRunGlobal = await tryRunGlobalWindow(
    windowManagement: windowManagement,
    packageInfo: packageInfo,
  );
  if (didRunGlobal) return;

  runInstanceWindowApp(windowManagement: windowManagement);
}

/// Builds the ordered list of pre-flight gates the app evaluates at
/// startup. Every engine builds the same list so that the primary
/// engine's `pickInitialGate` and a gate engine's `advance` agree.
List<StartupGate> _buildStartupGates(EulaAcceptance eulaAcceptance) {
  return [
    EulaGate(
      globalWindowKey: kEulaWindowKey,
      acceptance: eulaAcceptance,
      skip: kDebugMode && DebugConfig.skipEula,
    ),
  ];
}

/// Per-session work that should run exactly once, in whichever engine
/// took the primary launch slot. No-op for engines that didn't.
void _doFirstWindowMaintenance(WindowManagement wm) {
  if (!wm.isFirstWindowLaunched) return;
  AppSettings.doStartupMaintenance();
  runOpenGlobalsAtLaunch(wm);
}
