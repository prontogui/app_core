// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The style of license key for input validation.
enum LicenseKeyStyle {
  /// Any arbitrary characters
  arbitrary,

  /// GUID style key, e.g. a1b2c3d4-e5f6-7890-abcd-ef1234567890
  guid,

  /// Activation name
  activationName,
}

/// Settings for the differnt styles of license keys supported.
class LicenseKeyStyleSettings {
  LicenseKeyStyleSettings({this.inputFormatterRegex, this.caseSensitive = true, this.hintText, this.helperText, this.validatingFunction, this.canonizingFunction, this.obscuringFunction});

  /// The regex pattern for allowing input characters
  final String? inputFormatterRegex;

  /// The regex pattern is case sensitive when matching.
  final bool caseSensitive;

  /// Hint text to display for field.
  final String? hintText;

  /// Helper text to display for field.
  final String? helperText;

  /// Function (optional) that validates a submitted text value. Return null if valid or an error string.
  final String? Function(String)? validatingFunction;

  /// Function (optional) that reformats a presumeable valid input string to the canonical representation.
  final String Function(String)? canonizingFunction;

  /// A function (optional) that transforms a key text to an obscured key.
  final String Function(String)? obscuringFunction;
}

String _obscureArbitrary(String key) {
  return '*' * key.length;
}

String? _validateArbitrary(String input) {
  return null;
}

String _canonizeArbitrary(String input) {
  return input;
}

const kExpectedGuidLength = 32;

String _obscureGuid(String key) {
  return key.split('').map((c) {
    if (c == '-') {
      return c;
    }
    return 'X';
  }).join();
}

String _simplifyGuidInput(String input) {
  return input.replaceAll(RegExp(r'-'), '');
}

String? _validateGuid(String input) {
  if (input.isEmpty) {
    return null;
  }
  final simplifiedInput = _simplifyGuidInput(input);
  if (simplifiedInput.length < kExpectedGuidLength) {
    return 'Key is too short. Expecting $kExpectedGuidLength digits.';
  }
  if (simplifiedInput.length > kExpectedGuidLength) {
    return 'Key is too long. Expecting $kExpectedGuidLength digits.';
  }
  return null;
}

String _canonizeGuid(String input) {
  final s = _simplifyGuidInput(input);
  assert(s.length == kExpectedGuidLength, 'input is not a valid GUID');
  return '${s.substring(0, 8)}-${s.substring(8,12)}-${s.substring(12,16)}-${s.substring(16,20)}-${s.substring(20)}';
}

final _arbitraryLksSettings = LicenseKeyStyleSettings(
    caseSensitive: false,
    validatingFunction: _validateArbitrary,
    canonizingFunction: _canonizeArbitrary,
    obscuringFunction: _obscureArbitrary);
final _guidLksSettings = LicenseKeyStyleSettings(
    inputFormatterRegex: r'^[0-9a-f\-]*$',
    caseSensitive: false,
    helperText: 'Key format: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX',
    validatingFunction: _validateGuid,
    canonizingFunction: _canonizeGuid,
    obscuringFunction: _obscureGuid);
final _activationNameLksSettings = LicenseKeyStyleSettings(
    inputFormatterRegex: r'^$|^\S$|^\S.*\S$',
    caseSensitive: false,
    hintText: '',
    helperText: 'Maximum 25 characters with no spaces',
    obscuringFunction: _obscureArbitrary);

class LicenseKeyFieldValue {
  LicenseKeyFieldValue(this.enteredText, this.isValid);

  final String enteredText;
  final bool isValid;
}

/// A widget that provides viewing and editing a license key.
///
/// The `TextEntryField` widget allows users to input text and has
/// several configurable options to govern how text is displayed and entered.
///
/// This widget accepts [initialKey] which is a string representation of the
/// license ley.  When the user is finished editing, the new value is submitted back
/// via the provided handler [onSubmitted].
///
/// When the user is editing, the widget will restrict the total lenth of text
/// according to [maxLenth].
///
class LicenseKeyField extends StatefulWidget {
  const LicenseKeyField(
      {super.key,
      this.onSubmitted,
      this.initialKey,
      this.obscureKey = true,
      this.maxLength,
      this.textStyle,
      this.licenseKeyStyle = LicenseKeyStyle.arbitrary,
      this.labelText,
      });

  /// Handler for new key submitted after entering it. This is required for entering
  /// a key. If null then the key is view only.
  final void Function(LicenseKeyFieldValue)? onSubmitted;

  /// The initial key to display. If not provided then the field will be empty of text.
  final String? initialKey;

  /// True if the key's text should be obscured.
  final bool obscureKey;

  /// The maximum number of characters allowed (including whitespace).
  final int? maxLength;

  /// The text styling to use. If null then default styling from theme is used.
  final TextStyle? textStyle;

  /// The style of license key for input validation. Defaults to LicenseKeyStyle.arbitrary.
  final LicenseKeyStyle licenseKeyStyle;

  /// A label to display for the field (optional).
  final String? labelText;

  @override
  State<LicenseKeyField> createState() => _LicenseKeyFieldState();
}

/// The state representation of [LicenseKeyField].
class _LicenseKeyFieldState extends State<LicenseKeyField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  RegExp? _allowedInputRegex;
  String? _allowedInputRegexSource;
  late TextInputFormatter _inputFmt;

  // This field currently has focus.
  bool _hasFocus = false;

  // The last value submitted back via onSubmitted handler.  Null means that no
  // value has been submitted yet.
  String? _submittedText;

  late LicenseKeyStyleSettings _lksSettings;

  String? _validationError;

  // Builds a regex for the allowed input pattern.
  void buildAllowedInputPattern() {
    String? pattern;
    bool? caseSensitive = true;

    pattern = _lksSettings.inputFormatterRegex;
    caseSensitive = _lksSettings.caseSensitive;

    if (pattern != null) {
      // Has pattern changed since last time we built a regex?
      if (_allowedInputRegexSource != null && pattern == _allowedInputRegexSource) {
        return;
      }
      _allowedInputRegexSource = pattern;
      _allowedInputRegex = RegExp(pattern, caseSensitive: caseSensitive);
      return;
    }
    _allowedInputRegex = null;
    _allowedInputRegexSource = null;
  }
  
  String obscureIfNeeded(String s) {
    final obscuringFunction = _lksSettings.obscuringFunction;
      if (widget.obscureKey && obscuringFunction != null) {
        return obscuringFunction(s);
      }
      return s;
  }

  /// Prepares the initial text (if provided to widget) to display while making
  /// sure it meets any constraints.  If no initialValue was provided then it defaults
  /// to empty text.
  String prepareInitialText() {
    // Use the initial value?
    var text = widget.initialKey;

    if (text != null) {
      return obscureIfNeeded(checkAgainstConstraints(text).$2);
    }

    return '';
  }

  /// The string to use for editing text (not editing).
  String get editingText {
    if (_submittedText != null) {
      return obscureIfNeeded(_submittedText!);
    }
    return prepareInitialText();
  }

  /// The string to use for displaying text (not editing).
  String get displayText {
    // For now, simply return the editing text. In the future, we might present the entered text
    // differently when not editing, as governed by widget settings.
    return editingText;
  }

  /// Focus change handler for the text entry field.
  void onFocusChange() {
    setState(
      () {
        _hasFocus = _focusNode.hasPrimaryFocus;
      },
    );

    // If getting focus...
    if (_hasFocus) {
      if (_isEditing) {
        _controller.selection =
            TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
      } else {
        _controller.selection =
            TextSelection(baseOffset: -1, extentOffset:-1);
      }
    } else {
      // Store the edited value
      submitText(_controller.text);

      // Show the display value and remove selection
      _controller.text = displayText;
      _controller.selection =
          const TextSelection(baseOffset: -1, extentOffset: -1);
    }
  }

  /// Checks [text] against the min and max constraints. If [text] is within the max limits
  /// then it returns [text]. If [text] exceeds a limit then it clipped accordingly.
  (bool, String) checkAgainstConstraints(String text) {

    var constrained = false;
    var maxLength = widget.maxLength;

    // Exceed max length (if specified)?
    if (maxLength != null && text.length > maxLength) {
      constrained = true;
      text = text.substring(0, maxLength);
    }

    var pattern = _allowedInputRegex;

    if (pattern != null && !pattern.hasMatch(text)) {
      constrained = true;
      // Policy for now: return empty string if no regex match.
      text = '';
    }

    return (constrained, text);
  }

  void _resetValidationError() {
    setState(() {
      _validationError = null;
    });
  }

  bool get _isEditing {
    return widget.onSubmitted != null;
  }

  /// Submits the edited text back to the handler provided to this widget.
  ///
  /// [text] must be a valid text string (as defined by constraints)
  /// or it can be empty. If the text hasn't changed from the last time
  /// it was submitted then no callback is made.
  void submitText(String text) {

    var submitValue = checkAgainstConstraints(text).$2;
    final validationFunction = _lksSettings.validatingFunction;
    String? error;
    if (validationFunction != null) {
      error = validationFunction(submitValue);
    }
    if (error != null) {
      setState(() {
        _validationError = error;
      });
    } else {
      _resetValidationError();

      if (submitValue.isNotEmpty) {
        final canonizingFunction = _lksSettings.canonizingFunction;
        if (canonizingFunction != null) {
          submitValue = canonizingFunction(submitValue);
        }
      }
    }

    // Do nothing if text hasn't changed
    if (_submittedText != null && submitValue == _submittedText) {
      return;
    }
    _submittedText = submitValue;

    final onSubmitted = widget.onSubmitted;
    if (onSubmitted != null) {
      onSubmitted(LicenseKeyFieldValue(submitValue, _validationError == null));
    }
  }

  void _initLksSettings() {
    switch (widget.licenseKeyStyle) {
    case LicenseKeyStyle.arbitrary:
      _lksSettings = _arbitraryLksSettings;
    case LicenseKeyStyle.guid:
      _lksSettings = _guidLksSettings;
    case LicenseKeyStyle.activationName:
      _lksSettings = _activationNameLksSettings;
    }
  }

  // Standard overrides

  @override
  void initState() {
    super.initState();

    _initLksSettings();
    buildAllowedInputPattern();

    _inputFmt = TextInputFormatter.withFunction(
      (TextEditingValue oldValue, TextEditingValue newValue) {
        if (checkAgainstConstraints(newValue.text).$1) {
          return oldValue;
        }
        return newValue;
      },
    );

    _controller = TextEditingController(text: displayText);
    _focusNode = FocusNode();
    _focusNode.addListener(onFocusChange);
  }

  @override
  void dispose() {
    _allowedInputRegex = null;
    _allowedInputRegexSource = null;
    _controller.dispose();
    _focusNode.removeListener(onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    _initLksSettings();
    buildAllowedInputPattern();
    _hasFocus = false;
    _controller.text = prepareInitialText();
    _submittedText = null;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    Widget? errorWidget() {
      final error = _validationError;
      if (error != null) {
        return Text(error);
      }
      return null;
    }

    late InputDecoration decoration;
    InputBorder? border;
    if (!_hasFocus || !_isEditing) {
      border = InputBorder.none;
    }

    // Use the theme provided settings but don't show the border.
    decoration = InputDecoration(
      border: border,
      error: _isEditing ? errorWidget() : null,
      hintText: _isEditing ? _lksSettings.hintText : null,
      helperText: _isEditing ? _lksSettings.helperText : null,
      labelText: widget.labelText,
    );
  
    return Container(
        color: theme.colorScheme.surfaceContainer,
        child: TextField(
          controller: _controller,
          decoration: decoration,
          onSubmitted:(value) => submitText(value),
          focusNode: _focusNode,
          inputFormatters: [_inputFmt],
//            obscureText: widget.obscureKey,
//            obscuringCharacter: _defaultHidingCharacter,
          style: widget.textStyle,
          textAlign: TextAlign.center,
          showCursor: _isEditing,
          readOnly: !_isEditing,
        )
      );
  }
}
