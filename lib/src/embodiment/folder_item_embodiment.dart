// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// All rights reserved. Use of this source code is governed by the
// proprietary license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:dartlib/dartlib.dart' as pg;
import 'embodiment_manifest.dart';
import 'embodiment_help.dart';
import 'embodiment_args.dart';
import 'properties.dart';
import '../embodifier.dart';

EmbodimentPackageManifest getManifest() {
  return EmbodimentPackageManifest('FolderItem', [
    EmbodimentManifestEntry(
        'default', FolderItemEmbodiment.fromArgs, CommonProperties.fromMap),
  ]);
}

class FolderItemEmbodiment extends StatelessWidget {
  FolderItemEmbodiment.fromArgs(this.args, {super.key})
      : folderItem = args.primitive as pg.FolderItem;

  final EmbodimentArgs args;
  final pg.FolderItem folderItem;

  @override
  Widget build(BuildContext context) {
    if (folderItem.collapsed) {
      return collapsedContent();
    }

    Widget content;
    if (folderItem.item != null) {
      var embodifier = InheritedEmbodifier.of(context);
      content = embodifier.buildPrimitive(context, folderItem.item!);
    } else {
      content = const SizedBox.shrink();
    }

    return encloseWithPBMSAF(content, args, status: folderItem.status);
  }
}
