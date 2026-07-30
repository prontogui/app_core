// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:package_info_plus/package_info_plus.dart';

import '../about_view.dart';
import '../licensing_credits_view.dart';
import '../event_log_viewer.dart';
import '../eula_view.dart';
import '../global_windows.dart';
import '../settings_view.dart';
import '../window/window_management.dart';

const _kEulaAssetPath = 'assets/legal/eula.md';

/// Identifier for the current EULA version. Bump when the EULA text changes
/// so users are re-prompted to accept the new terms.
const _kEulaVersion = '2026-07-29';

/// If this engine's role is to render one of this package's global
/// windows, builds the appropriate `*Info` and calls `runApp` for it,
/// returning true. Otherwise returns false so the caller can either fall
/// through to instance-window setup, or — for an app that layers more
/// global windows on top of this package — try its own dispatch first
/// and call this function as the fallback for everything else.
///
/// Each branch is self-contained — the only cross-branch concern is
/// that the constructed app uses [windowManagement] as its handle for
/// further global-window operations.
///
/// This is the free-edition dispatcher: it has no notion of licensing,
/// so the About window it builds always has `showLicenseDetails: false`.
/// Apps that layer licensing on top supply their own About branch before
/// falling back to this function.
Future<bool> tryRunGlobalWindow({
  required WindowManagement windowManagement,
  required PackageInfo packageInfo,
}) async {
  switch (windowManagement.globalWindowKey) {
    case kLogWindowKey:
      runApp(EventLogApp());
      return true;

    case kSettingsWindowKey:
      runApp(SettingsApp());
      return true;

    case kAboutWindowKey:
      final aboutInfo = AboutInfo(
        appName: 'ProntoGUI™',
        version: packageInfo.version,
        statusSubtitle: 'Free Edition',
        globalAboutWindowKey: kAboutWindowKey,
        globalLicensingCreditsWindowKey: kLicensingCreditsWindowKey,
        showLicenseDetails: false,
      );
      runApp(AboutApp(info: aboutInfo));
      return true;

    case kEulaWindowKey:
      final eulaText = await rootBundle.loadString(_kEulaAssetPath);
      final eulaInfo = EulaInfo(
        appName: 'ProntoGUI™',
        version: packageInfo.version,
        licenseText: eulaText,
        eulaVersion: _kEulaVersion,
        globalEulaWindowKey: kEulaWindowKey,
      );
      runApp(EulaApp(info: eulaInfo));
      return true;

    case kLicensingCreditsWindowKey:
      runApp(LicensingCreditsApp(
        appName: 'ProntoGUI™',
        version: packageInfo.version,
      ));
      return true;

    default:
      return false;
  }
}
