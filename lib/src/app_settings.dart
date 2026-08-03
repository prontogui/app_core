// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:flutter/material.dart';
import 'package:dartlib/log.dart';

import 'storage/kv_store.dart';

/// App-wide settings storage for theme and other global preferences.
class AppSettings {
  AppSettings._internal(this._prefs, this._theme);

  static AppSettings? _instance;
  static AppSettings get instance => _instance!;

  /// The current version of storage. Incremented when needed throughout software
  /// lifecycle as needed to perform upgrades of preferences data.
  static const int _kCurrentStorageVersion = 1;

  /// Prefix for all storage keys used by app settings.
  static const _kStorageKeyPrefix = 'PGAppSettings';

  /// Storage version key.
  static const _kStorageVersionKey = '${_kStorageKeyPrefix}StorageVersion';

  /// Theme setting key.
  static const _kAppThemeKey = '${_kStorageKeyPrefix}Theme';

  static const _kDefaultTheme = 'light';

  final KvStore _prefs;
  String _theme;

  /// Performs maintenance work on preferences storage, such as clearing out
  /// old data and performing upgrades.
  static Future<void> doStartupMaintenance() async {
    final prefs = await KvStore.instance();
    int? storageVer;
    try {
      storageVer = await prefs.getInt(_kStorageVersionKey);
    } catch (_) {
    }

    if (storageVer == null || storageVer != _kCurrentStorageVersion) {
      bootLogger.i('detected App settings are at version $storageVer; upgrading to version $_kCurrentStorageVersion');

      // Remove all keys that start with our prefix
      final allValues = await prefs.getAll();
      for (var key in allValues.keys) {
        if (key.startsWith(_kStorageKeyPrefix)) {
          await prefs.remove(key);
        }
      }

      // Create initial information
      await prefs.setInt(_kStorageVersionKey, _kCurrentStorageVersion);
    }
  }

  /// Creates and initializes the singleton AppSettings instance.
  static Future<AppSettings> create() async {
    if (_instance != null) {
      return _instance!;
    }

    final prefs = await KvStore.instance();
    final theme = await prefs.getString(_kAppThemeKey) ?? _kDefaultTheme;
    _instance = AppSettings._internal(prefs, theme);
    return _instance!;
  }

  /// Current theme ('light' or 'dark').
  String get theme => _theme;

  /// Sets the theme and persists it to storage.
  Future<void> setTheme(String value) async {
    if (_theme == value) return;
    _theme = value;
    await _prefs.setString(_kAppThemeKey, value);
  }

  /// Reloads the theme from storage (for cross-window sync).
  Future<void> reload() async {
    _theme = await _prefs.getString(_kAppThemeKey) ?? _kDefaultTheme;
  }

  /// Light theme data.
  ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      );

  /// Dark theme data.
  ThemeData get darkTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );

  /// Returns ThemeMode based on current theme setting.
  ThemeMode get themeMode =>
      _theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
}
