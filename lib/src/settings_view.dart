// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:flutter/material.dart';
import 'app_settings.dart';
import 'window/window_management.dart';

/// The Settings window application.
class SettingsApp extends StatefulWidget {
  const SettingsApp({super.key});

  @override
  State<SettingsApp> createState() => _SettingsAppState();
}

class _SettingsAppState extends State<SettingsApp> {
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
      title: 'Settings',
      theme: AppSettings.instance.lightTheme,
      darkTheme: AppSettings.instance.darkTheme,
      themeMode: AppSettings.instance.themeMode,
      home: const Scaffold(body: SettingsView()),
    );
  }
}

/// The Settings view content.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String _selectedTheme = AppSettings.instance.theme;

  Future<void> _onThemeChanged(Set<String> selection) async {
    if (selection.isEmpty) return;
    final newTheme = selection.first;
    setState(() {
      _selectedTheme = newTheme;
    });
    await AppSettings.instance.setTheme(newTheme);
    await WindowManagement.instance.broadcastThemeChange(newTheme);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Theme',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(width: 24),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'light',
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode),
                  ),
                  ButtonSegment<String>(
                    value: 'dark',
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode),
                  ),
                ],
                selected: {_selectedTheme},
                onSelectionChanged: _onThemeChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
