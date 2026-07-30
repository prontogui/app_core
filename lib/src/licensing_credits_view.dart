// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// All rights reserved. Use of this source code is governed by the
// proprietary license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'app_settings.dart';
import 'window/window_management.dart';

/// The Licensing Credits window application.
///
/// Shows the open-source licenses for every package the app depends on
/// via Flutter's built-in [showLicensePage]. The license page is pushed
/// automatically when the window first opens; the [LicensingCreditsView]
/// backdrop remains underneath so the user can re-open it after
/// navigating back.
class LicensingCreditsApp extends StatefulWidget {
  const LicensingCreditsApp({
    super.key,
    required this.appName,
    required this.version,
  });

  final String appName;
  final String version;

  @override
  State<LicensingCreditsApp> createState() => _LicensingCreditsAppState();
}

class _LicensingCreditsAppState extends State<LicensingCreditsApp> {
  @override
  void initState() {
    super.initState();
    WindowManagement.instance.notifyThemeChanged.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    WindowManagement.instance.notifyThemeChanged.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<void> _onThemeChanged() async {
    await AppSettings.instance.reload();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Licensing Credits',
      theme: AppSettings.instance.lightTheme,
      darkTheme: AppSettings.instance.darkTheme,
      themeMode: AppSettings.instance.themeMode,
      home: Scaffold(
        body: LicensingCreditsView(
          appName: widget.appName,
          version: widget.version,
        ),
      ),
    );
  }
}

/// The Licensing Credits view content — a backdrop with a button that
/// opens Flutter's license page. The license page is also shown
/// automatically the first time the window appears.
class LicensingCreditsView extends StatefulWidget {
  const LicensingCreditsView({
    super.key,
    required this.appName,
    required this.version,
  });

  final String appName;
  final String version;

  @override
  State<LicensingCreditsView> createState() => _LicensingCreditsViewState();
}

class _LicensingCreditsViewState extends State<LicensingCreditsView> {
  @override
  void initState() {
    super.initState();
    // Show the license page as soon as the window is on screen.
    WidgetsBinding.instance.addPostFrameCallback((_) => _showLicenses());
  }

  void _showLicenses() {
    if (!mounted) return;

    showLicensePage(
      context: context,
      applicationName: widget.appName,
      applicationVersion: 'Version ${widget.version}',
      applicationIcon: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset('assets/app_icon.png', width: 64, height: 64),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset('assets/app_icon.png', width: 64, height: 64),
            ),
            const SizedBox(height: 16),
            Text(
              'Licensing Credits',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Open-source licenses for the packages used by ${widget.appName}.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color
                    ?.withAlpha((0.7 * 255).round()),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _showLicenses,
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Show Licensing Credits'),
            ),
          ],
        ),
      ),
    );
  }
}
