// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

/// Compile-time switches for development and debugging.
///
/// Edit the values below to toggle behavior, then rebuild. None of these
/// flags do anything in release builds — call sites gate every override
/// on `kDebugMode`. The intent is to make it easy to toggle alternate
/// behaviors during local development without scattering `kDebugMode`
/// checks across the codebase.
///
/// Conventions:
///   - Each flag's *production* value is the field's initializer here.
///   - The flag is consulted at the call site, gated on `kDebugMode`
///     wherever the production behavior would otherwise be unconditional.
///
/// This is the free-edition config — it has no notion of licensing.
/// Apps that layer licensing on top of this package (see the proprietary
/// `app` repo) define their own debug-config extension for that.
class DebugConfig {
  DebugConfig._();

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  /// Render the Flutter `WindowMenuBar` on macOS. Off in production
  /// because macOS uses the system menu bar (`MainMenu.xib`); turn on
  /// to test the cross-platform menu without changing platform.
  static const bool showFlutterMenuOnMacOS = false;

  /// Pin the theme to a specific value, ignoring `AppSettings`.
  /// `'light'`, `'dark'`, or empty for no override.
  static const String forceTheme = '';

  /// Show the standard Flutter visual debug overlays. Wired through
  /// `debugPaintSizeEnabled` and `debugRepaintRainbowEnabled` in
  /// `main.dart`.
  static const bool debugPaintBoundaries = false;
  static const bool debugPaintRepaintRainbow = false;

  /// Show the Flutter performance overlay (UI + raster thread frame
  /// times) on every `MaterialApp`. Wired through
  /// `MaterialApp.showPerformanceOverlay` in `app.dart`.
  static const bool showPerformanceOverlay = false;

  // ---------------------------------------------------------------------------
  // State / persistence
  // ---------------------------------------------------------------------------

  /// Wipe the kv-backed app state at launch. Equivalent to deleting
  /// `pg_app.db` between runs. Removes window settings, app settings,
  /// EULA acceptance, etc. — i.e. simulates a first launch.
  static const bool resetKvStoreOnLaunch = false;

  /// Bypass the EULA gate at launch. The acceptance record is left
  /// untouched on disk; this only short-circuits the "show EULA window"
  /// branch in `main.dart`.
  static const bool skipEula = false;

  // ---------------------------------------------------------------------------
  // Window management
  // ---------------------------------------------------------------------------

  /// Open one or more global windows immediately at launch. Values:
  ///   - `''`    — open none (production behavior)
  ///   - `'*'`   — open every global defined in `allGlobalWindowSettings`
  ///   - comma-separated keys (e.g. `'EULA,SETTINGS'`) — open just those
  static const String openGlobalsAtLaunch = '';
}
