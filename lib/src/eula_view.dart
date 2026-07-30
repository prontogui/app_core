// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// All rights reserved. Use of this source code is governed by the
// proprietary license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'app_settings.dart';
import 'eula_acceptance.dart';
import 'json_help.dart';
import 'startup/startup_sequence.dart';
import 'window/window_management.dart';

/// Information to display in the EULA window.
class EulaInfo {
  const EulaInfo({
    required this.appName,
    required this.version,
    required this.licenseText,
    required this.eulaVersion,
    required this.globalEulaWindowKey,
  });

  final String appName;
  final String version;
  final String licenseText;
  final String eulaVersion;
  final String globalEulaWindowKey;
}

/// The EULA window application.
class EulaApp extends StatefulWidget {
  const EulaApp({super.key, required this.info});

  final EulaInfo info;

  @override
  State<EulaApp> createState() => _EulaAppState();
}

class _EulaAppState extends State<EulaApp> {
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
      title: 'End User License Agreement',
      theme: AppSettings.instance.lightTheme,
      darkTheme: AppSettings.instance.darkTheme,
      themeMode: AppSettings.instance.themeMode,
      home: Scaffold(body: EulaView(info: widget.info)),
    );
  }
}

/// The EULA view content.
class EulaView extends StatefulWidget {
  const EulaView({super.key, required this.info});

  final EulaInfo info;

  @override
  State<EulaView> createState() => _EulaViewState();
}

class _EulaViewState extends State<EulaView> {
  Future<void> _onAcceptPressed() async {
    await EulaAcceptance.instance.recordAcceptance(widget.info.eulaVersion);
    await StartupSequence.instance.advance();
    if (!mounted) return;
    setState(() {});
  }

  void _onDeclinePressed() {
    WindowManagement.instance.hideGlobalWindow(widget.info.globalEulaWindowKey);
  }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              _buildSubHeader(context),
              const SizedBox(height: 24),
              Expanded(child: _buildLicenseBody(context)),
              const SizedBox(height: 16),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      'End User License Agreement',
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w400,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      '${widget.info.appName}  •  Version ${widget.info.version}',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.textTheme.bodyMedium?.color?.withAlpha((0.7 * 255).round()),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLicenseBody(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Markdown(
        data: widget.info.licenseText,
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(theme),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final acceptance = EulaAcceptance.instance;
    final alreadyAccepted =
        acceptance.isAccepted && acceptance.eulaVersion == widget.info.eulaVersion;

    if (alreadyAccepted) {
      return _buildAcceptedFooter(context, acceptance.acceptanceDate);
    }
    return _buildAcceptDeclineFooter(context);
  }

  Widget _buildAcceptedFooter(BuildContext context, DateTime? acceptedOn) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          acceptedOn == null
              ? 'Accepted'
              : 'Accepted on ${dateToString(acceptedOn.toLocal())}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withAlpha((0.7 * 255).round()),
          ),
        ),
        OutlinedButton(
          onPressed: _onDeclinePressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.primary,
            side: BorderSide(color: colorScheme.primary),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildAcceptDeclineFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: _onDeclinePressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.primary,
            side: BorderSide(color: colorScheme.primary),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: const Text('Decline'),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: _onAcceptPressed,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: const Text('I Accept'),
        ),
      ],
    );
  }
}
