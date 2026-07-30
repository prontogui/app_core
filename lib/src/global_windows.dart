// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:flutter/material.dart';

import 'window/window_management.dart';

const kLogWindowKey = 'LOG';
const kSettingsWindowKey = 'SETTINGS';
const kAboutWindowKey = 'ABOUT';
const kEulaWindowKey = 'EULA';
const kLicensingCreditsWindowKey = 'LICENSING_CREDITS';

/// The global windows this package defines. Apps that layer additional
/// global windows on top (e.g. a proprietary "Licensing" window) should
/// pass `[...coreGlobalWindowSettings, myExtraWindowSettings]` to
/// `WindowManagement.ensureInitialized`, and chain their own dispatch
/// function into `tryRunGlobalWindow` for the extra keys.
List<WindowSettings> get coreGlobalWindowSettings => [
      WindowSettings(windowKey: kLogWindowKey, size: Size(800, 600), title: 'Event Log'),
      WindowSettings(windowKey: kSettingsWindowKey, size: Size(400, 300), title: 'Settings', resetOnOpen: true),
      WindowSettings(windowKey: kAboutWindowKey, size: Size(500, 600), title: 'About', resetOnOpen: true),
      WindowSettings(windowKey: kEulaWindowKey, size: Size(700, 700), title: 'End User License Agreement', resetOnOpen: true),
      WindowSettings(windowKey: kLicensingCreditsWindowKey, size: Size(700, 700), title: 'Licensing Credits', resetOnOpen: true),
    ];
