// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:dartlib/dartlib.dart' as pg;
import 'package:flutter/material.dart';
import 'embodiment_manifest.dart';
import 'embodiment_args.dart';
import 'embodiment_help.dart';
import 'properties.dart';
import 'labelitem_mixin.dart';
import '../embodifier.dart';

EmbodimentPackageManifest getManifest() {
  return EmbodimentPackageManifest('Tristate', [
    EmbodimentManifestEntry(
        'default', TristateEmbodiment.fromArgs, TristateDefaultProperties.fromMap),
  ]);
}

class TristateEmbodiment extends StatefulWidget {
  TristateEmbodiment.fromArgs(this.args, {super.key})
      : tristate = args.primitive as pg.Tristate,
        props = args.properties as TristateDefaultProperties;

  final EmbodimentArgs args;
  final pg.Tristate tristate;
  final TristateDefaultProperties props;

  @override
  State<TristateEmbodiment> createState() {
    return _TristateEmbodimentState();
  }
}

class _TristateEmbodimentState extends State<TristateEmbodiment> with LabelAndLabelItem {
  // Called when user clicks directly on the Checkbox widget
  void setCurrentState(bool? newState) {
    // Ignore if Disaabled
    if (!widget.tristate.enabled) {
      return;
    }

    setState(() {
      widget.tristate.stateAsBool = newState;
    });
  }

  // Called when the user clicks on the label
  void nextState() {
    // Ignore if Disaabled
    if (!widget.tristate.enabled) {
      return;
    }

    setState(() {
      widget.tristate.nextState();
    });
  }

  @override
  Widget build(BuildContext context) {

    var tristate = widget.tristate;

    if (tristate.collapsed) {
      return collapsedContent();
    }

    var props = widget.props;
    var embodifier = InheritedEmbodifier.of(context);

    Widget cb = Checkbox(
      value: tristate.stateAsBool,
      onChanged: (bool? value) {
        setCurrentState(value);
      },
      tristate: true,
    );

    return buildCheckboxWithLabelContent(
      context,
      embodifier,
      widget.args,
      tristate.label,
      tristate.labelItem,
      props.labelItemPosition,
      'tristate "default" embodiment',
      onTap: () => nextState(),
      checkbox: cb,
      checkBoxPosition: props.checkBoxPosition,
      status: tristate.status,
    );
  }
}
