import 'dart:async';

import 'package:dartlib/log.dart';

import '../storage/kv_store.dart';
import 'window_settings.dart';

/// Persistence layer for a single window's [WindowSettings].
///
/// One row per window keyed by `windowKey` — for instance windows the key
/// is a UUID assigned by `windowController.windowId`, for global windows
/// it's a constant defined by the app (e.g. `LOG`, `ABOUT`). Both kinds
/// share one flat namespace; whether a particular row is "global" is
/// answered by checking its key against the app-supplied list of
/// global keys, not by its storage location.
///
/// Storage layout in [KvStore]:
///   `PGWindowMgmtSchemaVersion`             → int, schema version
///   `PGWindowMgmtDefaultWindowSettings`     → JSON, defaults for new windows
///   `PGWindowMgmtWindowSettings/<windowKey>` → JSON, one window's settings
class WindowSettingsStorage {

  WindowSettingsStorage._(this._kv, this.settings, this._globalWindowKeys);

  /// Bumped when on-disk layout changes. doStartupMaintenance wipes all
  /// window-management keys when the stored version doesn't match.
  static const int _kCurrentStorageVersion = 1;

  /// Max instance windows enforced by [canSpawnInstanceWindow]. Globals
  /// don't count against this cap. Defaults to effectively unlimited;
  /// set via [WindowManagement.ensureInitialized]'s `maxInstanceWindows`
  /// parameter so the embedding app controls it (e.g. `1` for a
  /// single-instance-window edition).
  static int maxInstanceWindows = 20;

  static const _kStorageKeyPrefix = 'PGWindowMgmt';
  static const _kStorageVersionKey = '${_kStorageKeyPrefix}SchemaVersion';
  static const _kDefaultKey = '${_kStorageKeyPrefix}DefaultWindowSettings';
  static const _kSettingsKeyPrefix = '${_kStorageKeyPrefix}WindowSettings/';

  static String _settingsKey(String windowKey) => '$_kSettingsKeyPrefix$windowKey';

  final KvStore _kv;
  WindowSettings settings;
  final List<String> _globalWindowKeys;
  Timer? _delayedSaveTimer;

  String get windowKey => settings.windowKey;

  /// True if our window is a global window.
  bool get isGlobalWindow => _globalWindowKeys.contains(windowKey);

  /// Performs maintenance at app launch:
  ///   - On schema version mismatch, wipes all window-management keys.
  ///   - For instance windows, prunes any row whose stored visibility
  ///     isn't `visible` (closed/hidden windows from the prior session).
  ///   - For global windows, preserves the row but resets visibility to
  ///     `none` so the new session can claim them.
  static Future<void> doStartupMaintenance(List<String> globalWindowKeys) async {
    final kv = await KvStore.instance();

    int? storageVer;
    try {
      storageVer = await kv.getInt(_kStorageVersionKey);
    } catch (_) {}

    if (storageVer == null || storageVer != _kCurrentStorageVersion) {
      bootLogger.i('upgrading window storage to version $_kCurrentStorageVersion (was $storageVer)');
      final all = await kv.getAll();
      for (final key in all.keys) {
        if (key.startsWith(_kStorageKeyPrefix)) {
          await kv.remove(key);
        }
      }
      await kv.setInt(_kStorageVersionKey, _kCurrentStorageVersion);
      return;
    }

    final globalKeySet = globalWindowKeys.toSet();
    final all = await kv.getAll();
    for (final entry in all.entries) {
      if (!entry.key.startsWith(_kSettingsKeyPrefix)) continue;
      final json = entry.value;
      if (json is! String || json.isEmpty) continue;
      final s = WindowSettings.fromJson(json);
      if (s.invalid) {
        await kv.remove(entry.key);
        continue;
      }
      if (globalKeySet.contains(s.windowKey)) {
        // Globals keep their settings; reset their runtime visibility.
        s.visibility = WindowVisibility.none;
        await kv.setString(entry.key, s.toJSON());
      } else if (s.visibility != WindowVisibility.visible) {
        // Instance windows that weren't visible at shutdown are stale.
        await kv.remove(entry.key);
      }
    }
  }

  /// Removes the row keyed by [windowKey] from storage. No-op if the
  /// row doesn't exist. Use when re-keying a window (see the empty-arg
  /// path in `WindowManagement.create`) or when permanently discarding
  /// a window's settings.
  static Future<void> remove(String windowKey) async {
    final kv = await KvStore.instance();
    await kv.remove(_settingsKey(windowKey));
  }

  /// Open existing settings for [windowKey]. Throws if no row exists or
  /// the stored JSON is invalid.
  static Future<WindowSettingsStorage> open(String windowKey, List<String> globalWindowKeys) async {
    final kv = await KvStore.instance();
    final json = await kv.getString(_settingsKey(windowKey));
    if (json == null || json.isEmpty) {
      throw Exception('Could not find settings for windowKey: $windowKey');
    }
    final settings = WindowSettings.fromJson(json);
    if (settings.invalid) {
      throw Exception('Stored settings for $windowKey are invalid');
    }
    return WindowSettingsStorage._(kv, settings, globalWindowKeys);
  }

  /// Create a fresh settings object for [windowKey], seeded from the
  /// stored defaults. Caller must call [save] to persist.
  static Future<WindowSettingsStorage> create(String windowKey, List<String> globalWindowKeys) async {
    final kv = await KvStore.instance();
    final settings = WindowSettings.fromJson(await kv.getString(_kDefaultKey), isDirty: true);
    settings.windowKey = windowKey;
    return WindowSettingsStorage._(kv, settings, globalWindowKeys);
  }

  /// Wrap a clone of an existing [WindowSettings] (e.g. a global-window
  /// template supplied by the app) without touching storage. The clone
  /// is what's stored — later mutations through the storage's settings
  /// don't leak back into the shared template.
  ///
  /// The clone is always clean. Whether to overwrite the kv row with
  /// the cloned values is the caller's decision, expressed via
  /// [save]'s `force` argument — typically gated on the source's
  /// [WindowSettings.resetOnOpen].
  static Future<WindowSettingsStorage> createFromSettings(WindowSettings windowSettings, List<String> globalWindowKeys) async {
    final kv = await KvStore.instance();
    return WindowSettingsStorage._(kv, windowSettings.clone(), globalWindowKeys);
  }

  /// Returns windowKeys for every instance window with stored settings,
  /// in arbitrary order.
  static Future<List<String>> listInstanceWindows(List<String> globalWindowKeys) async {
    final kv = await KvStore.instance();
    final globalKeySet = globalWindowKeys.toSet();
    final all = await kv.getAll();
    final keys = <String>[];
    for (final entry in all.entries) {
      if (!entry.key.startsWith(_kSettingsKeyPrefix)) continue;
      final json = entry.value;
      if (json is! String || json.isEmpty) continue;
      final s = WindowSettings.fromJson(json);
      if (s.invalid) continue;
      if (globalKeySet.contains(s.windowKey)) continue;
      keys.add(s.windowKey);
    }
    return keys;
  }

  /// Returns details for every instance window with stored settings.
  static Future<List<WindowDetails>> listInstanceWindowDetails(List<String> globalWindowKeys) async {
    final kv = await KvStore.instance();
    final globalKeySet = globalWindowKeys.toSet();
    final all = await kv.getAll();
    final details = <WindowDetails>[];
    for (final entry in all.entries) {
      if (!entry.key.startsWith(_kSettingsKeyPrefix)) continue;
      final json = entry.value;
      if (json is! String || json.isEmpty) continue;
      final s = WindowSettings.fromJson(json);
      if (s.invalid) continue;
      if (globalKeySet.contains(s.windowKey)) continue;
      details.add(WindowDetails(s.windowKey, s.title, s.host, s.port));
    }
    return details;
  }

  /// Returns the windowKey of any instance window currently marked
  /// `hidden`, or null if none. Used by `newInstanceWindow` to repurpose
  /// an existing hidden isolate instead of spawning a new one.
  static Future<String?> findHiddenInstanceWindow(List<String> globalWindowKeys) async {
    final kv = await KvStore.instance();
    final globalKeySet = globalWindowKeys.toSet();
    final all = await kv.getAll();
    for (final entry in all.entries) {
      if (!entry.key.startsWith(_kSettingsKeyPrefix)) continue;
      final json = entry.value;
      if (json is! String || json.isEmpty) continue;
      final s = WindowSettings.fromJson(json);
      if (s.invalid) continue;
      if (s.visibility != WindowVisibility.hidden) continue;
      if (globalKeySet.contains(s.windowKey)) continue;
      return s.windowKey;
    }
    return null;
  }

  /// Whether a new instance window can be spawned without exceeding
  /// [maxInstanceWindows]. Globals don't count.
  static Future<bool> canSpawnInstanceWindow(List<String> globalWindowKeys) async {
    final list = await listInstanceWindows(globalWindowKeys);
    return list.length < maxInstanceWindows;
  }

  /// Counts windows whose persisted visibility is `visible`. Used by
  /// `WindowManagement._closeoutWindow` to detect "no visible windows
  /// remain" and trigger app-wide clean shutdown on Windows. Counts
  /// instance and global windows alike — once all are dismissed, the
  /// process should exit.
  ///
  /// Reads from KvStore directly so each engine sees writes from
  /// sibling engines (SQLite WAL serializes across the per-engine
  /// connections).
  static Future<int> countVisibleWindows() async {
    final kv = await KvStore.instance();
    final all = await kv.getAll();
    var count = 0;
    for (final entry in all.entries) {
      if (!entry.key.startsWith(_kSettingsKeyPrefix)) continue;
      final json = entry.value;
      if (json is! String || json.isEmpty) continue;
      final s = WindowSettings.fromJson(json);
      if (s.invalid) continue;
      if (s.visibility == WindowVisibility.visible) count++;
    }
    return count;
  }

  /// Reads the persisted visibility for the window identified by
  /// [windowKey]. Returns [WindowVisibility.none] when no row exists or
  /// the JSON is invalid — i.e. no live isolate currently owns it.
  static Future<WindowVisibility> getStoredVisibility(String windowKey) async {
    final kv = await KvStore.instance();
    final json = await kv.getString(_settingsKey(windowKey));
    if (json == null || json.isEmpty) {
      return WindowVisibility.none;
    }
    return WindowSettings.fromJson(json).visibility;
  }

  /// The default window settings as a JSON string. Empty when none stored.
  Future<String> getDefaultSettingsJson() async {
    final json = await _kv.getString(_kDefaultKey);
    return json ?? '';
  }

  /// Reload [settings] from storage at our current [windowKey]. Returns
  /// true if a valid record was loaded, false if the row was missing or
  /// invalid.
  Future<bool> reload() async {
    final json = await _kv.getString(_settingsKey(windowKey));
    if (json == null || json.isEmpty) {
      return false;
    }
    final loaded = WindowSettings.fromJson(json, isDirty: false);
    if (loaded.invalid) {
      return false;
    }
    settings = loaded;
    return true;
  }

  /// Save [settings] to storage, optionally with a 2-second debounce.
  ///
  /// Skips the write when [settings] has no unsaved changes (clean), so
  /// most callers can call this freely without worrying about churning
  /// kv. Pass `force: true` to write regardless of dirty state — used
  /// when the caller has just installed a fresh in-memory copy (e.g.
  /// after `createFromSettings` for a `resetOnOpen` global) and wants
  /// to ensure kv is brought into agreement.
  Future<void> save({bool delayed = false, bool force = false}) async {
    void doSave() async {
      if (!force && !settings.isDirty) return;
      await _kv.setString(_settingsKey(windowKey), settings.toJSON());
    }

    _cancelDelayedSaveTimer();
    if (delayed) {
      _delayedSaveTimer = Timer(const Duration(seconds: 2), doSave);
    } else {
      doSave();
    }
  }

  void _cancelDelayedSaveTimer() {
    _delayedSaveTimer?.cancel();
    _delayedSaveTimer = null;
  }
}
