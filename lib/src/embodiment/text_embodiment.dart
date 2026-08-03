// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:flutter/material.dart';
import 'package:dartlib/dartlib.dart' as pg;
import 'embodiment_manifest.dart';
import 'embodiment_args.dart';
import 'embodiment_help.dart';
import 'properties.dart' as p;

EmbodimentPackageManifest getManifest() {
  return EmbodimentPackageManifest('Text', [
    EmbodimentManifestEntry(
        'default', TextEmbodiment.fromArgs, p.TextDefaultProperties.fromMap),
  ]);
}

class TextEmbodiment extends StatelessWidget {
  const TextEmbodiment.fromArgs(this.args, {super.key});

  final EmbodimentArgs args;

  @override
  Widget build(BuildContext context) {
    var text = args.primitive as pg.Text;
  
    if (text.collapsed) {
      return collapsedContent();
    }

//    var props = args.properties as p.TextDefaultProperties;

    // TODO: do we need to handle hidden status here?
    if (args.noEnclosures) {
      return buildStyledText(text.content, args.properties, simpleAlignment: true);
    }

    return encloseWithPBMSAF(
      buildStyledText(text.content, args.properties),
      args,
      status: text.status
    );
  }
}
