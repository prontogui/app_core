// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// All rights reserved. Use of this source code is governed by the
// proprietary license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'app_settings.dart';
import 'window/window_management.dart';

/// Information to display in the About window.
///
/// When [showLicenseDetails] is false (e.g. the free Personal edition), the
/// license/valid-through rows, renewal notice, and Manage License button are
/// omitted, and [licenseType], [validThrough], [renewalNotice],
/// [globalLicensingWindowKey], and [manageLicenseLabel] are not read.
class AboutInfo {
  const AboutInfo({
    required this.appName,
    required this.version,
    required this.statusSubtitle,
    required this.globalAboutWindowKey,
    required this.globalLicensingCreditsWindowKey,
    this.showLicenseDetails = true,
    this.licenseType = '',
    this.validThrough = '',
    this.renewalNotice = '',
    this.globalLicensingWindowKey = '',
    this.manageLicenseLabel = '',
  });

  final String appName;
  final String version;
  final String statusSubtitle;
  final bool showLicenseDetails;
  final String licenseType;
  final String validThrough;
  final String renewalNotice;
  final String globalAboutWindowKey;
  final String globalLicensingWindowKey;
  final String globalLicensingCreditsWindowKey;
  final String manageLicenseLabel;
}

/// The About window application.
class AboutApp extends StatefulWidget {
  const AboutApp({super.key, required this.info});

  final AboutInfo info;

  @override
  State<AboutApp> createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
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
      title: 'About',
      theme: AppSettings.instance.lightTheme,
      darkTheme: AppSettings.instance.darkTheme,
      themeMode: AppSettings.instance.themeMode,
      home: Scaffold(body: AboutView(info: widget.info)),
    );
  }
}

/// The About view content.
class AboutView extends StatelessWidget {
  const AboutView({super.key, required this.info});

  final AboutInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [colorScheme.surface, colorScheme.surface]
              : [colorScheme.primaryContainer.withAlpha((0.3 * 255).round()), colorScheme.surface],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 1),
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildLogo(context),
                const SizedBox(height: 32),
                _buildStatusSection(context),
                if (info.showLicenseDetails) ...[
                  const SizedBox(height: 24),
                  _buildInfoSection(context),
                  const SizedBox(height: 16),
                  _buildRenewalNotice(context),
                ],
                const Spacer(flex: 2),
                if (info.showLicenseDetails) ...[
                  _buildManageButton(context),
                  const SizedBox(height: 8),
                ],
                _buildLicensingCreditsButton(context),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      info.appName,
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/app_icon.png',
        width: 80,
        height: 80,
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Version ${info.version}',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          info.statusSubtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withAlpha((0.7 * 255).round()),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerColor;

    return Column(
      children: [
        _buildDashedDivider(dividerColor),
        const SizedBox(height: 16),
        _buildInfoRow(context, 'License', info.licenseType),
        const SizedBox(height: 12),
        _buildDashedDivider(dividerColor),
        const SizedBox(height: 16),
        _buildInfoRow(context, 'Valid Through', info.validThrough),
        const SizedBox(height: 12),
        _buildDashedDivider(dividerColor),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge,
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDashedDivider(Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashWidth = 5.0;
        final dashSpace = 3.0;
        final dashCount =
            (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color.withAlpha((0.5 * 255).round())),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildRenewalNotice(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      info.renewalNotice,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.textTheme.bodySmall?.color?.withAlpha((0.7 * 255).round()),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildManageButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: () {
        WindowManagement.instance.openGlobalWindow(info.globalLicensingWindowKey);
        WindowManagement.instance.hideGlobalWindow(info.globalAboutWindowKey);
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: Text(info.manageLicenseLabel),
    );
  }

  Widget _buildLicensingCreditsButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        WindowManagement.instance
            .openGlobalWindow(info.globalLicensingCreditsWindowKey);
      },
      child: const Text('Show Licensing Credits'),
    );
  }

}
