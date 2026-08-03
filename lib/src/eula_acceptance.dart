// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:dartlib/log.dart';
import 'json_help.dart';
import 'machine_id.dart';
import 'storage/kv_store.dart';

/// Persists whether the user has accepted the End User License Agreement,
/// along with the acceptance date, machine ID, and EULA version.
///
/// A single [KvStore] key holds a JSON blob, and the stored machine ID is
/// validated against the current machine on load so that a copied blob from
/// another machine is rejected.
class EulaAcceptance {
  EulaAcceptance._defaults(this._machineIdProvider, this._storage);

  EulaAcceptance._fromJson(
    String json,
    String thisMachineId,
    this._machineIdProvider,
    this._storage,
  ) {
    _loadFromJson(json, thisMachineId);
  }

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final MachineIdProvider _machineIdProvider;
  final EulaAcceptanceStorage _storage;

  // ---------------------------------------------------------------------------
  // Persisted fields
  // ---------------------------------------------------------------------------

  bool _accepted = false;
  DateTime? _acceptanceDate;
  String _machineId = '';
  String _eulaVersion = '';

  bool get isAccepted => _accepted;
  DateTime? get acceptanceDate => _acceptanceDate;
  String get machineId => _machineId;
  String get eulaVersion => _eulaVersion;

  // ---------------------------------------------------------------------------
  // Singleton
  // ---------------------------------------------------------------------------

  static EulaAcceptance? _instance;

  static EulaAcceptance get instance => _instance!;
  static EulaAcceptance? get instanceOrNull => _instance;

  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  // ---------------------------------------------------------------------------
  // Factory
  // ---------------------------------------------------------------------------

  static Future<EulaAcceptance> create({
    MachineIdProvider? machineIdProvider,
    EulaAcceptanceStorage? storage,
  }) async {
    if (_instance != null) {
      throw Exception('Cannot create EulaAcceptance more than once. It is singleton.');
    }

    final midProvider = machineIdProvider ?? DeviceMachineIdProvider();
    final eulaStorage = storage ?? KvStoreEulaAcceptanceStorage();

    final thisMachineId = await midProvider.getMachineId();
    if (thisMachineId == null) {
      logger.w('Unsupported operating system for EULA acceptance tracking');
      _instance = EulaAcceptance._defaults(midProvider, eulaStorage);
      return _instance!;
    }

    final json = await eulaStorage.load();
    if (json == null || json.isEmpty) {
      _instance = EulaAcceptance._defaults(midProvider, eulaStorage);
      return _instance!;
    }

    _instance = EulaAcceptance._fromJson(json, thisMachineId, midProvider, eulaStorage);
    return _instance!;
  }

  /// Reloads acceptance state from storage. Call this after another window
  /// has updated the persisted record.
  Future<void> reload() async {
    final thisMachineId = await _machineIdProvider.getMachineId();
    if (thisMachineId == null) return;

    final json = await _storage.load();
    if (json == null || json.isEmpty) {
      _resetFields();
      return;
    }

    try {
      _loadFromJson(json, thisMachineId);
    } catch (e) {
      logger.e('Error reloading EULA acceptance: $e');
    }
  }

  /// Records that the user has accepted the given EULA version. Persists
  /// immediately.
  Future<void> recordAcceptance(String eulaVersion) async {
    final thisMachineId = await _machineIdProvider.getMachineId();
    if (thisMachineId == null) {
      logger.w('Cannot record EULA acceptance: unsupported OS');
      return;
    }

    _accepted = true;
    _acceptanceDate = DateTime.now().toUtc();
    _machineId = thisMachineId;
    _eulaVersion = eulaVersion;

    final data = <String, dynamic>{
      'accepted': _accepted,
      'acceptanceDate': _acceptanceDate!.toIso8601String(),
      'machineId': _machineId,
      'eulaVersion': _eulaVersion,
    };

    await _storage.save(jsonEncode(data));
  }

  void _resetFields() {
    _accepted = false;
    _acceptanceDate = null;
    _machineId = '';
    _eulaVersion = '';
  }

  void _loadFromJson(String json, String thisMachineId) {
    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    } catch (_) {
      _resetFields();
      return;
    }

    final jh = JSONFieldDecoder(data);

    final storedMachineId = jh.asString('machineId', '');
    if (storedMachineId.isEmpty || storedMachineId != thisMachineId) {
      logger.w('EULA acceptance record was saved on a different machine — ignoring');
      _resetFields();
      return;
    }

    _accepted = jh.asBool('accepted', false);
    _acceptanceDate = jh.asDateTime('acceptanceDate');
    _machineId = storedMachineId;
    _eulaVersion = jh.asString('eulaVersion', '');
  }
}

/// Loads and saves the EULA acceptance JSON blob.
abstract class EulaAcceptanceStorage {
  Future<String?> load();
  Future<void> save(String data);
}

/// Production implementation — persists via [KvStore].
class KvStoreEulaAcceptanceStorage implements EulaAcceptanceStorage {
  static const _kStorageKey = 'PGEulaAcceptance';

  @override
  Future<String?> load() async {
    final prefs = await KvStore.instance();
    return prefs.getString(_kStorageKey);
  }

  @override
  Future<void> save(String data) async {
    final prefs = await KvStore.instance();
    await prefs.setString(_kStorageKey, data);
  }
}
