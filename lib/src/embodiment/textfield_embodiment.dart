// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'embodiment_help.dart';
import 'package:dartlib/dartlib.dart' as pg;
import 'package:flutter/material.dart';
import '../widgets/text_field.dart' as tef;
import 'embodiment_manifest.dart';
import 'embodiment_args.dart';
import 'properties.dart';
import 'embodiment_common.dart';

EmbodimentPackageManifest getManifest() {
  return EmbodimentPackageManifest('TextField', [
    EmbodimentManifestEntry(
        'default', TextFieldEmbodiment.fromArgs, TextFieldDefaultProperties.fromMap),
  ]);
}

class TextFieldEmbodiment extends StatelessWidget {
  TextFieldEmbodiment.fromArgs(this.args, {super.key})
      : textfield = args.primitive as pg.TextField,
        props = args.properties as TextFieldDefaultProperties;

  final EmbodimentArgs args;
  final pg.TextField textfield;
  final TextFieldDefaultProperties props;

  @override
  Widget build(BuildContext context) {

    if (textfield.collapsed) {
      return collapsedContent();
    }

    var content = tef.TextEntryField(
      initialText: textfield.textEntry,
      minDisplayLines: props.minDisplayLines,
      maxDisplayLines: props.maxDisplayLines,
      maxLength: props.maxLength,
      maxLines: props.maxLines,  
      hideText: props.hideText,
      hidingCharacter: props.hidingCharacter,
      focusSelection: adaptFocusSelection(props.focusSelection),
      onSubmitted: (text) {
        textfield.textEntry = text;
      },
      textStyle: buildTextStyle(props),
      backgroundColor: props.backgroundColor,
    );

    return encloseWithPBMSAF(
      content,
      args,
      horizontalUnbounded: true,
      status: textfield.status
    );
  }
}
