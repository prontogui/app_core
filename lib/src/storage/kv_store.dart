/// Cross-platform key/value store backed by SQLite.
///
/// Replaces the slice of `SharedPreferencesAsync` this app uses, with two
/// concrete improvements:
///
///   * Safe concurrent access from multiple Flutter engines. Each window
///     spawned via `desktop_multi_window` opens its own connection to the
///     same database file; SQLite serializes writes via WAL-mode file
///     locks. With shared_preferences on Windows/Linux (a single JSON
///     file rewritten per call), concurrent writes from sibling engines
///     could clobber each other.
///   * Identical behavior on every platform.
///
/// Uses `package:sqlite3` directly rather than `sqflite_common_ffi`. The
/// sqflite wrapper spawns a worker isolate per Database connection — when
/// multiple Flutter engines (one per window) each open the same file,
/// the cross-engine combination of worker isolates and prepared-statement
/// caching has been observed to throw `SQLITE_MISUSE`. Talking to SQLite
/// directly via FFI (which is what `package:sqlite3` does) has no
/// worker-isolate hop and avoids the bug.
///
/// The exposed surface intentionally mirrors the methods this app already
/// calls on `SharedPreferencesAsync` so call sites change only in type and
/// import. All values are stored as TEXT; ints round-trip via
/// `int.parse`/`toString`. Methods are async even though the underlying
/// SQLite calls are synchronous, so call sites keep the same shape and we
/// retain the option to move heavy queries onto a background isolate
/// later without churning callers.
library;

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class KvStore {
  KvStore._(this._db);

  final Database _db;

  static const _kDbFileName = 'pg_app.db';

  static Future<KvStore>? _opening;

  /// Returns the per-engine [KvStore], opening it on first call.
  ///
  /// Each Flutter engine (each window in a multi-window app) holds its own
  /// connection to the same on-disk database; SQLite handles the locking.
  static Future<KvStore> instance() {
    final existing = _opening;
    if (existing != null) return existing;
    final future = _open();
    _opening = future;
    return future.catchError((Object e, StackTrace s) {
      _opening = null;
      throw e;
    });
  }

  /// Opens an in-memory store. Intended for tests; never persists.
  static KvStore openInMemory() {
    final db = sqlite3.openInMemory();
    _configure(db);
    _createSchema(db);
    return KvStore._(db);
  }

  static Future<KvStore> _open() async {
    final dir = await getApplicationSupportDirectory();
    final path = p.join(dir.path, _kDbFileName);
    final db = sqlite3.open(path);
    _configure(db);
    _createSchema(db);
    return KvStore._(db);
  }

  static void _configure(Database db) {
    // WAL is the load-bearing pragma — it's what makes concurrent
    // writers from sibling Flutter engines safe.
    db.execute('PRAGMA journal_mode = WAL');
    db.execute('PRAGMA synchronous = NORMAL');
    db.execute('PRAGMA busy_timeout = 5000');
  }

  static void _createSchema(Database db) {
    db.execute(
      'CREATE TABLE IF NOT EXISTS kv (key TEXT PRIMARY KEY, value TEXT)',
    );
  }

  Future<String?> getString(String key) async {
    final rs = _db.select(
      'SELECT value FROM kv WHERE key = ? LIMIT 1',
      [key],
    );
    if (rs.isEmpty) return null;
    return rs.first['value'] as String?;
  }

  Future<void> setString(String key, String value) async {
    _db.execute(
      'INSERT OR REPLACE INTO kv (key, value) VALUES (?, ?)',
      [key, value],
    );
  }

  Future<int?> getInt(String key) async {
    final s = await getString(key);
    if (s == null) return null;
    return int.tryParse(s);
  }

  Future<void> setInt(String key, int value) async {
    await setString(key, value.toString());
  }

  Future<void> remove(String key) async {
    _db.execute('DELETE FROM kv WHERE key = ?', [key]);
  }

  /// Removes every entry. Intended for debug/testing — wipes all
  /// app state stored in this kv table.
  Future<void> clearAll() async {
    _db.execute('DELETE FROM kv');
  }

  /// Returns key→value entries. If [allowList] is non-null, only those
  /// keys are included; missing keys are simply absent from the result
  /// (matching `SharedPreferencesAsync.getAll`). Values are always
  /// returned as `String?`.
  Future<Map<String, Object?>> getAll({Set<String>? allowList}) async {
    if (allowList != null && allowList.isEmpty) return const {};
    final rs = _db.select('SELECT key, value FROM kv');
    return {
      for (final row in rs)
        if (allowList == null || allowList.contains(row['key']))
          row['key'] as String: row['value'],
    };
  }
}
