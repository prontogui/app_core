// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:app_core/src/embodiment/embodiment_help.dart';
import 'package:dartlib/dartlib.dart' as pg;
import 'package:flutter/material.dart';
import 'embodiment_manifest.dart';
import 'embodiment_args.dart';
import 'properties.dart';
import '../embodifier.dart';
import 'labelitem_mixin.dart';
import 'dart:convert';

EmbodimentPackageManifest getManifest() {
  return EmbodimentPackageManifest('Check', [
    EmbodimentManifestEntry(
        'default', CheckDefaultEmbodiment.fromArgs, CheckDefaultProperties.fromMap),
    EmbodimentManifestEntry(
        'toggle-button', CheckToggleButtonEmbodiment.fromArgs, CheckToggleButtonProperties.fromMap),

  ]);
}

class CheckDefaultEmbodiment extends StatefulWidget {
  CheckDefaultEmbodiment.fromArgs(this.args, {super.key})
      : check = args.primitive as pg.Check,
      props = args.properties as CheckDefaultProperties;

  final EmbodimentArgs args;
  final pg.Check check;
  final CheckDefaultProperties props;

  @override
  State<CheckDefaultEmbodiment> createState() {
    return _CheckDefaultEmbodimentState();
  }
}

class _CheckDefaultEmbodimentState extends State<CheckDefaultEmbodiment> with LabelAndLabelItem {

  // Called when user clicks directly on the Checkbox widget
  void setCurrentChecked(bool newChecked) {
    // Ignore if Disaabled
    if (!widget.check.enabled) {
      return;
    }

    setState(() {
      widget.check.checked = newChecked;
    });
  }

  // Called when the user clicks on the label
  void nextState() {
    // Ignore if Disaabled
    if (!widget.check.enabled) {
      return;
    }

    setState(() {
      widget.check.nextState();
    });
  }

  @override
  Widget build(BuildContext context) {
    var embodifier = InheritedEmbodifier.of(context);

    var check = widget.check;
    var props = widget.props;

    if (check.collapsed) {
      return collapsedContent();
    }

    var cb = Checkbox(
      value: check.checked,
      onChanged: (bool? value) {
        if (value == null) {
          setCurrentChecked(false);
        } else {
          setCurrentChecked(value);
        }
      },
      tristate: false,
    );

    return buildCheckboxWithLabelContent(
      context,
      embodifier,
      widget.args,
      check.label,
      check.labelItem,
      props.labelItemPosition,
      'check "default" embodiment',
      onTap: () => nextState(),
      checkbox: cb,
      checkBoxPosition: props.checkBoxPosition,
      status: check.status,
    );
  }
}

class CheckToggleButtonEmbodiment extends StatefulWidget {
  CheckToggleButtonEmbodiment.fromArgs(this.args, {super.key})
      : check = args.primitive as pg.Check;

  final EmbodimentArgs args;
  final pg.Check check;

  @override
  State<CheckToggleButtonEmbodiment> createState() {
    return _CheckToggleButtonEmbodimentState();
  }
}

class _CheckToggleButtonEmbodimentState extends State<CheckToggleButtonEmbodiment> with LabelAndLabelItem {

  late CheckToggleButtonProperties _props;
  //CommonPropertyAccess? _propertiesForChecked;
  //CommonPropertyAccess? _propertiesForUnchecked;

  // Called when user clicks directly on the Checkbox widget
  void setCurrentChecked(bool newChecked) {
   // Ignore if Disaabled
    if (!widget.check.enabled) {
      return;
    }

    setState(() {
      widget.check.checked = newChecked;
    });
  }

  // Called when the user clicks on the label
  void nextState() {
   // Ignore if Disaabled
    if (!widget.check.enabled) {
      return;
    }

    setState(() {
      widget.check.nextState();
    });
  }

  @override
  void initState() {
    // First, call super
    super.initState();

    _props = widget.args.properties as CheckToggleButtonProperties;
  }

  @override
  void didUpdateWidget(covariant oldWidget) {

    _props = widget.args.properties as CheckToggleButtonProperties;

    // Lastly, call super
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {

    // Lastly, call super
    super.dispose();
  }

  CommonPropertyAccess _selectPropsOrDefault(CommonPropertyAccess? props, String defaultPropertiesJson) {
    if (props != null) {
      return props;
    }

    return CommonProperties.fromMap(jsonDecode(defaultPropertiesJson));
  }

  @override
  Widget build(BuildContext context) {

    var check = widget.check;

    if (check.collapsed) {
      return collapsedContent();
    }

    var embodifier = InheritedEmbodifier.of(context);
    var theme = Theme.of(context);

    late CommonPropertyAccess altProps;

    if (widget.check.checked) {
      altProps = _selectPropsOrDefault(_props.propertiesForChecked, '{"backgroundColor":"${colorToHexValue(theme.colorScheme.inversePrimary)}"}');
    } else {
      altProps = _selectPropsOrDefault(_props.propertiesForUnchecked, '{}');
    }

    return buildCheckboxWithLabelContent(
      context,
      embodifier,
      widget.args,
      check.label,
      check.labelItem,
      _props.labelItemPosition,
      'check "toggle-button" embodiment',
      onTap: () => nextState(),
      altProps: altProps,
      status: check.status,
    );
  }
}
