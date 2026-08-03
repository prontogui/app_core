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

EmbodimentPackageManifest getManifest() {
  return EmbodimentPackageManifest('Command', [
    EmbodimentManifestEntry('default', ElevatedButtonCommandEmbodiment.fromArgs,
        CommandDefaultProperties.fromMap),
    EmbodimentManifestEntry('outlined-button',
        OutlinedButtonCommandEmbodiment.fromArgs, CommandOutlinedButtonProperties.fromMap),
  ]);
}

class ElevatedButtonCommandEmbodiment extends StatelessWidget with LabelAndLabelItem {
  ElevatedButtonCommandEmbodiment.fromArgs(this.args, {super.key})
    : props = args.properties as CommandDefaultProperties;

  final EmbodimentArgs args;
  final CommandDefaultProperties props;

  @override
  Widget build(BuildContext context) {
    var command = args.primitive as pg.Command;

    if (command.collapsed) {
      return collapsedContent();
    }

    var embodifier = InheritedEmbodifier.of(context);

    var innerContent = buildCheckboxWithLabelContent(
      context,
      embodifier,
      args,
      command.label,
      command.labelItem,
      props.labelItemPosition,
      'command "default" embodiment',
      status: command.status
    );

    var content = ElevatedButton(
      onPressed: command.issueNow,
      child: innerContent,
    );

    return encloseWithPBMSAF(
      content,
      args,
      status: command.status
    );
  }
}

class OutlinedButtonCommandEmbodiment extends StatelessWidget with LabelAndLabelItem {
  OutlinedButtonCommandEmbodiment.fromArgs(this.args, {super.key})
    : props = args.properties as CommandOutlinedButtonProperties;


  final EmbodimentArgs args;
  final CommandOutlinedButtonProperties props;

  @override
  Widget build(BuildContext context) {
    var command = args.primitive as pg.Command;
  
    if (command.collapsed) {
      return collapsedContent();
    }

    var embodifier = InheritedEmbodifier.of(context);

    var innerContent = buildCheckboxWithLabelContent(
      context,
      embodifier,
      args,
      command.label,
      command.labelItem,
      props.labelItemPosition,
      'command "outlined-button" embodiment',
      status: command.status
    );

    var content = OutlinedButton(
      onPressed: command.issueNow,
      child: innerContent,
    );

    return encloseWithPBMSAF(
      content,
      args,
      status: command.status
    );
  }
}
