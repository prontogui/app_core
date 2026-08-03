// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:flutter/material.dart';
import 'package:dartlib/dartlib.dart' as pg;
import 'icon_map.dart';
import 'embodiment_manifest.dart';
import 'embodiment_help.dart';
import 'embodiment_args.dart';
import 'properties.dart';

EmbodimentPackageManifest getManifest() {
  return EmbodimentPackageManifest('Icon', [
    EmbodimentManifestEntry('default', IconDefaultEmbodiment.fromArgs,
        IconDefaultProperties.fromMap),
  ]);
}

class IconDefaultEmbodiment extends StatelessWidget {
  const IconDefaultEmbodiment.fromArgs(this.args, {super.key});

  final EmbodimentArgs args;

  @override
  Widget build(BuildContext context) {
    var icon = args.primitive as pg.Icon;

    if (icon.collapsed) {
      return collapsedContent();
    }

    var props = args.properties as IconDefaultProperties;

    var content = Icon(translateIdToIconData(icon.iconID),
        color: props.color, size: props.size);

    return encloseWithPBMSAF(
      content,
      args,
      status: icon.status
    );
  }
}
