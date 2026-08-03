// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'window_management.dart';

/// Builds a shortcut activator using the platform-conventional primary
/// modifier: ⌘ (meta) on macOS, Ctrl on Windows/Linux. The rendered label
/// in the menu picks up the correct symbol automatically.
SingleActivator _shortcut(LogicalKeyboardKey key) {
  final isMac = defaultTargetPlatform == TargetPlatform.macOS;
  return SingleActivator(key, meta: isMac, control: !isMac);
}

/// Cross-platform menu bar rendered inside the Flutter view.
///
/// Mirrors the Win32 menu in `windows/runner/flutter_window.cpp` so
/// every window gets the same menu — primary or secondary, on every
/// platform — without per-platform native plumbing.
///
/// Mount as the topmost child of your view body, e.g.:
///
///   Scaffold(
///     body: WindowMenuBar(
///       logWindowKey: kLogWindowKey,
///       settingsWindowKey: kSettingsWindowKey,
///       aboutWindowKey: kAboutWindowKey,
///       configureWindowMessage: 'configure_window',
///       child: yourBody,
///     ),
///   )
///
/// Keyboard shortcuts (Ctrl+N, Ctrl+K, Ctrl+W, Ctrl+,) are registered by
/// [MenuItemButton.shortcut] — they fire whenever this widget is in the
/// tree, no separate accelerator-table setup needed.
class WindowMenuBar extends StatelessWidget {
  const WindowMenuBar({
    super.key,
    required this.logWindowKey,
    required this.settingsWindowKey,
    required this.aboutWindowKey,
    required this.configureWindowMessage,
    required this.child,
  });

  final String logWindowKey;
  final String settingsWindowKey;
  final String aboutWindowKey;

  /// Payload sent to the focused instance window when the user picks
  /// File → Configure Window.
  final String configureWindowMessage;

  final Widget child;

  WindowManagement get _wm => WindowManagement.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MenuBar(
          style: const MenuStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
          ),
          children: [
            SubmenuButton(
              menuChildren: [
                if (WindowManagement.allowsMultipleInstanceWindows) ...[
                  MenuItemButton(
                    shortcut: _shortcut(LogicalKeyboardKey.keyN),
                    onPressed: () => _wm.newInstanceWindow(),
                    child: const Text('New Window'),
                  ),
                  const Divider(height: 1),
                ],
                MenuItemButton(
                  shortcut: _shortcut(LogicalKeyboardKey.keyK),
                  onPressed: () => _wm.sendMessageToFocusedInstanceWindow(configureWindowMessage),
                  child: const Text('Configure Window'),
                ),
                const Divider(height: 1),
                MenuItemButton(
                  shortcut: _shortcut(LogicalKeyboardKey.keyW),
                  onPressed: () => _wm.closeFocusedInstanceWindow(),
                  child: const Text('Close Window'),
                ),
                const Divider(height: 1),
                MenuItemButton(
                  shortcut: _shortcut(LogicalKeyboardKey.comma),
                  onPressed: () => _wm.openGlobalWindow(settingsWindowKey),
                  child: const Text('Settings'),
                ),
                const Divider(height: 1),
                MenuItemButton(
                  onPressed: () => ShutdownCoordinator.instance.requestShutdown(),
                  child: const Text('Exit'),
                ),
              ],
              child: const Text('File'),
            ),
            SubmenuButton(
              menuChildren: [
                MenuItemButton(
                  onPressed: () => _wm.openGlobalWindow(logWindowKey),
                  child: const Text('Show Log...'),
                ),
              ],
              child: const Text('View'),
            ),
            SubmenuButton(
              menuChildren: [
                MenuItemButton(
                  onPressed: () => launchUrl(Uri.parse('https://prontogui.com/support/')),
                  child: const Text('Developer Documentation'),
                ),
                MenuItemButton(
                  onPressed: () => launchUrl(Uri.parse('https://prontogui.com/support/release-notes/')),
                  child: const Text('Release Notes'),
                ),
                const Divider(height: 1),
                MenuItemButton(
                  onPressed: () => launchUrl(Uri.parse('https://prontogui.com/contact-us/')),
                  child: const Text('Provide Feedback'),
                ),
                const Divider(height: 1),
                MenuItemButton(
                  onPressed: () => _wm.openGlobalWindow(aboutWindowKey),
                  child: const Text('About'),
                ),
              ],
              child: const Text('Help'),
            ),
          ],
        ),
        Expanded(child: child),
      ],
    );
  }
}
