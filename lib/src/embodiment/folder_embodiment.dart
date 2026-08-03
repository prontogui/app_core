// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:flutter/material.dart';
import 'package:dartlib/dartlib.dart' as pg;
import 'embodiment_manifest.dart';
import 'embodiment_help.dart';
import 'embodiment_args.dart';
import 'properties.dart';
import '../embodifier.dart';

EmbodimentPackageManifest getManifest() {
  return EmbodimentPackageManifest('Folder', [
    EmbodimentManifestEntry(
        'default', FolderEmbodiment.fromArgs, FolderDefaultProperties.fromMap),
  ]);
}

class FolderEmbodiment extends StatelessWidget {
  FolderEmbodiment.fromArgs(this.args, {super.key})
      : folder = args.primitive as pg.Folder,
        props = args.properties as FolderDefaultProperties;

  final EmbodimentArgs args;
  final pg.Folder folder;
  final FolderDefaultProperties props;

  @override
  Widget build(BuildContext context) {
    if (folder.collapsed) {
      return collapsedContent();
    }

    IconData iconData;
    switch (props.folderIcons) {
      case FolderIcons.chevron:
        iconData = folder.expanded ? Icons.expand_more : Icons.chevron_right;
      case FolderIcons.fileFolder:
        iconData = folder.expanded ? Icons.folder_open_rounded : Icons.folder_rounded;
      case FolderIcons.plusMinus:
        iconData = folder.expanded ? Icons.remove : Icons.add;
    }

    var expandIcon = Icon(
      iconData,
      size: 20.0,
    );

    var embodifier = InheritedEmbodifier.of(context);

    Widget labelContent;
    if (folder.labelItem != null) {
      labelContent = embodifier.buildPrimitive(context, folder.labelItem!);
    } else {
      labelContent = const SizedBox.shrink();
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: folder.status == 0
              ? () {
                  folder.expanded = !folder.expanded;
                  embodifier.notifyBuilder(pg.PKey.parentOf(folder.pkey));
                }
              : null,
          child: expandIcon,
        ),
        Expanded(child: labelContent),
      ],
    );

    return encloseWithPBMSAF(content, args, status: folder.status);
  }
}
