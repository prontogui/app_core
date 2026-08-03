// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import '../eula_acceptance.dart';

/// A single pre-flight gate evaluated at app startup.
///
/// Each gate is represented at runtime by a global window (e.g. EULA,
/// future "Updates Available") and is "pending" if storage says the
/// user hasn't satisfied it yet. [StartupSequence] walks the gate list
/// in order; the first pending one decides what the primary engine
/// launches as.
///
/// [isPending] must be answerable from durable storage alone — gate
/// engines run in their own Flutter engines and each constructs its
/// own [StartupSequence], so two engines must agree on every decision
/// without any in-memory or live-IPC state.
abstract class StartupGate {
  /// The global window key that renders this gate.
  String get globalWindowKey;

  /// True if the gate still needs to be shown.
  Future<bool> isPending();
}

/// Gate that requires the user to accept the EULA before normal startup.
class EulaGate implements StartupGate {
  EulaGate({
    required this.globalWindowKey,
    required EulaAcceptance acceptance,
    bool skip = false,
  })  : _acceptance = acceptance,
        _skip = skip;

  @override
  final String globalWindowKey;

  final EulaAcceptance _acceptance;
  final bool _skip;

  @override
  Future<bool> isPending() async => !_skip && !_acceptance.isAccepted;
}
