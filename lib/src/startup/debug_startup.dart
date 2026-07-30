// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// All rights reserved. Use of this source code is governed by the
// proprietary license that can be found in the LICENSE file.

import 'package:dartlib/log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../debug_config.dart';
import '../storage/kv_store.dart';
import '../window/window_management.dart';

/// Applies the global debug-only side effects of [DebugConfig] that
/// must take effect before any subsystem reads state — Flutter's
/// debug-paint overlays and the optional kv-store wipe.
///
/// Must be called after [WindowManagement.ensureInitialized]. The
/// debug-paint flags are per-engine (each engine sets its own); the
/// kv-store wipe touches shared SQLite-backed storage and is gated
/// on [WindowManagement.isPrimaryEngine] so spawned engines don't
/// re-wipe state that a sibling engine has already populated.
///
/// No-op in release builds.
Future<void> applyDebugStartup() async {
  if (!kDebugMode) return;

  debugPaintSizeEnabled = DebugConfig.debugPaintBoundaries;
  debugRepaintRainbowEnabled = DebugConfig.debugPaintRepaintRainbow;

  if (DebugConfig.resetKvStoreOnLaunch && WindowManagement.isPrimaryEngine) {
    bootLogger.w('DebugConfig.resetKvStoreOnLaunch is set — wiping kv store');
    final kv = await KvStore.instance();
    await kv.clearAll();
  }
}

/// Opens the global windows requested by [DebugConfig.openGlobalsAtLaunch]
/// for the current engine. The spec is `''` (open none), `'*'` (open
/// every defined global), or a comma-separated list of window keys.
/// Unknown keys are logged and skipped.
///
/// No-op in release builds and when the spec is empty. Call from the
/// first-window maintenance block; subsequent engines must not call
/// this or the debug globals will multiply.
void runOpenGlobalsAtLaunch(WindowManagement wm) {
  if (!kDebugMode) return;
  final spec = DebugConfig.openGlobalsAtLaunch;
  if (spec.isEmpty) return;

  final defined = WindowManagement.allGlobalWindowKeys.toSet();
  final keys = spec.trim() == '*'
      ? defined.toList()
      : spec.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
  for (final key in keys) {
    if (!defined.contains(key)) {
      bootLogger.w('DebugConfig.openGlobalsAtLaunch: unknown global window key "$key"');
      continue;
    }
    wm.openGlobalWindow(key);
  }
}
