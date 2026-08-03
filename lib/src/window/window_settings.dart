// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'dart:convert';
import 'package:flutter/material.dart';

import '../json_help.dart';

/// The various modes of displaying a window.
enum WindowDisplayMode { normal, centered }

/// Runtime visibility of a global window.
///
/// `none` indicates no live isolate currently owns the window — either the
/// window has never been opened or the app just launched. `visible` and
/// `hidden` describe the state of a live isolate's window. This field is
/// reset to `none` on every app boot by `doStartupMaintenance`; it is not a
/// persistent user preference.
enum WindowVisibility { none, visible, hidden }

/// The settings for a window. These are created from default settings when a new
/// window is created or they are created from a JSON string, which represents
/// the saved settings. Each setting has get/set accessors and it tracks when
/// settings have changed (dirty status) so settings are stored efficiently.
class WindowSettings {

  /// Default title for new instance windows.
  static const kDefaultTitle = 'Untitled';

  /// Build new settings using the specified values.
  ///
  /// [resetOnOpen] is a template-only property for global windows: when
  /// true, every open of this global window discards any persisted
  /// size/position/etc. and re-applies the template's values. Default
  /// false (preserve user customizations across sessions). Not
  /// round-tripped through JSON since it's a property of the in-memory
  /// template, not user state.
  WindowSettings({
    String windowKey = '',
    String title = kDefaultTitle,
    Offset position = Offset.zero,
    Size size = const Size(800, 600),
    bool hiddenAtLaunch = false,
    bool resetOnOpen = false,
  }) {
    _isDirty = false;
    _windowKey = windowKey;
    _title = title;
    _host = '';  // Not used for global windows
    _port = 0;   // Not used for global windows
    _position = position;
    _size = size;
    _hiddenAtLaunch = hiddenAtLaunch;
    _displayMode = WindowDisplayMode.centered;
    _theme = 'light';
    _visibility = WindowVisibility.none;
    _resetOnOpen = resetOnOpen;
  }

  /// Create the settings from a JSON string (saved settings). When [json]
  /// is null or doesn't parse, the result is the same as `WindowSettings()`.
  factory WindowSettings.fromJson(String? json, {bool isDirty = false}) {
    final s = WindowSettings();
    s._isDirty = isDirty;

    if (json == null) return s;

    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map<String, dynamic>) return s;
      data = decoded;
    } catch (_) {
      return s;
    }

    final jh = JSONFieldDecoder(data);

    s._windowKey = jh.asString('windowKey', s._windowKey);
    s._title = jh.asString('title', s._title);
    s._host = jh.asString('host', s._host);
    s._port = jh.asInt('port', s._port);

    final positionX = jh.asDouble('position.dx');
    final positionY = jh.asDouble('position.dy');
    if (positionX != null && positionY != null) {
      s._position = Offset(positionX, positionY);
    }

    final width = jh.asDouble('size.width');
    final height = jh.asDouble('size.height');
    if (width != null && height != null) {
      s._size = Size(width, height);
    }

    s._hiddenAtLaunch = jh.asBool('hiddenAtLaunch', s._hiddenAtLaunch);
    s._displayMode = jh.asEnum<WindowDisplayMode>(
        'displayMode', WindowDisplayMode.values, s._displayMode);
    s._theme = jh.asString('theme', s._theme);
    s._visibility = jh.asEnum<WindowVisibility>(
        'visibility', WindowVisibility.values, s._visibility);

    return s;
  }

  /// Returns an independent copy of this settings object — useful when
  /// you need to wrap a shared template (e.g. an entry in
  /// `allGlobalWindowSettings`) without later mutations leaking back
  /// into it through the shared reference.
  ///
  /// The clone is always clean (`isDirty == false`). A caller that
  /// wants its values written to kv regardless should ask the storage
  /// to do so explicitly via [WindowSettingsStorage.save]'s `force`
  /// argument; cloning itself is purely a copy operation and stays
  /// out of the dirty-tracking concern.
  ///
  /// [resetOnOpen] is preserved on the clone — it travels with the
  /// in-memory object even though it's not persisted.
  WindowSettings clone() {
    final wasDirty = _isDirty;
    final c = WindowSettings.fromJson(toJSON(), isDirty: false);
    c._resetOnOpen = _resetOnOpen;
    // toJSON() clears _isDirty as a side effect; restore so cloning
    // is observably read-only on the original.
    _isDirty = wasDirty;
    return c;
  }

  /// Build a JSON string containing all the settings.
  String toJSON() {

    String enumToString(dynamic value) {
      final s = value.toString();
      return s.split('.')[1];
    }

    // Encode all settings into a JSON object
    final Map<String, dynamic> data = {
      'windowKey': _windowKey,
      'title': _title,
      'host': _host,
      'port': _port,
      'position.dx': _position.dx,
      "position.dy": _position.dy,
      'size.width': _size.width,
      'size.height': _size.height,
      'hiddenAtLaunch': _hiddenAtLaunch,
      'displayMode': enumToString(_displayMode),
      'theme': _theme,
      'visibility': enumToString(_visibility),
    };

    final json = jsonEncode(data);
    _isDirty = false;

    return json;
  }

  /// Dirty flag (i.e. not saved).
  late bool _isDirty;
  bool get isDirty => _isDirty;

  /// A unique key tying this window to stored settings. Its either a long UUID-like
  /// string or a global window key defined by our application to identify windows for settings,
  /// about, event log, etc.
  ///
  /// Special note
  /// ------------
  /// this is not the same as WindowController's windowID that is automatically generated
  /// during runtime for each window opened. However, when an instance window is created, the
  /// WindowController's windowId is used to initialie this property, because of its uniqueness.
  /// When a global window is opened then we assigned a simpler string to this property, such as LOG,
  /// ABOUT, or HELP. These simpler keys are considered global window keys defined by this application
  /// and correspond to "system level" windows that are singleton in nature.
  ///
  /// This is why we take special care to call it windowKey as opposed to windowId to avoid any confusion.
  String get windowKey => _windowKey;
  set windowKey(String value) {
    if (_windowKey == value) {
      return;
    }
    _windowKey = value;
    _isDirty = true;
  }
  late String _windowKey;

  /// Title to display for window.
  String get title => _title;
  set title(String value) {
    if (_title == value) {
      return;
    }
    _title = value;
    _isDirty = true;
  }
  late String _title;

  /// Server of GUI to connect to
  String get host => _host;
  set host(String value) {
    if (_host == value) {
      return;
    }
    _host = value;
    _isDirty = true;
  }
  late String _host;

  /// Port to use for connection
  int get port => _port;
  set port(int value) {
    if (_port == value) {
      return;
    }
    _port = value;
    _isDirty = true;
  }
  late int _port;

  /// Position of window on screen
  Offset get position => _position;
  set position(Offset value) {
    if (_position == value) {
      return;
    }
    _position = value;
    _isDirty = true;
  }
  late Offset _position;

  /// Whether the window is opened but hidden at launch of the App. This only
  /// applies to global windows.
  bool get hiddenAtLaunch => _hiddenAtLaunch;
  set hiddenAtLaunch(bool value) {
    if (_hiddenAtLaunch == value) {
      return;
    }
    _hiddenAtLaunch = value;
    _isDirty = true;
  }
  late bool _hiddenAtLaunch;

  /// Display mode of window
  WindowDisplayMode get displayMode => _displayMode;
  set displayMode(WindowDisplayMode value) {
    if (_displayMode == value) {
      return;
    }
    _displayMode = value;
    _isDirty = true;
  }
  late WindowDisplayMode _displayMode;

  /// Sizing of window
  Size get size => _size;
  set size(Size value) {
    if (_size == value) {
      return;
    }
    _size = value;
    _isDirty = true;
  }
  late Size _size;

  /// Theme to use ('light', 'dark', aso)
  String get theme => _theme;
  set theme(String value) {
    if (_theme == value) {
      return;
    }
    _theme = value;
    _isDirty = true;
  }
  late String _theme;

  /// Runtime visibility of a global window. Reset to [WindowVisibility.none]
  /// on every app boot — not a persistent user preference. Used by
  /// `WindowManagement` to decide whether a live isolate already owns the
  /// global window so it can be messaged instead of re-spawned.
  WindowVisibility get visibility => _visibility;
  set visibility(WindowVisibility value) {
    if (_visibility == value) {
      return;
    }
    _visibility = value;
    _isDirty = true;
  }
  late WindowVisibility _visibility;

  /// Template-only flag (global windows only): when true, every open
  /// or re-show of this window discards any persisted user state and
  /// re-applies the template's defaults. See the constructor for the
  /// full doc.
  ///
  /// Read-only at runtime — set via the constructor and copied across
  /// `clone()`. Not round-tripped through JSON.
  bool get resetOnOpen => _resetOnOpen;
  late bool _resetOnOpen;

  /// True if the settings are invalid for use
  bool get invalid {
    return windowKey.trim().isEmpty;
  }

}

/// Details about an open window.
class WindowDetails {
  WindowDetails(this.windowKey, this.title, this.host, this.port);

  final String windowKey;
  final String title;
  final String host;
  final int port;
}
