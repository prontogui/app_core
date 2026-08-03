// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import '../embodifier.dart';
import 'package:dartlib/dartlib.dart' as pg;
import 'package:flutter/material.dart';
import 'embodiment_manifest.dart';
import 'embodiment_args.dart';
import 'embodiment_help.dart';
import 'properties.dart';
import 'item_alignment_mixin.dart';

EmbodimentPackageManifest getManifest() {
  return EmbodimentPackageManifest('Group', [
    EmbodimentManifestEntry(
        'default', GroupDefaultEmbodiment.fromArgs, GroupDefaultProperties.fromMap),
  ]);
}

class GroupDefaultEmbodiment extends StatelessWidget with ItemAlignmentMixin {
  const GroupDefaultEmbodiment.fromArgs(this.args, {super.key});

  final EmbodimentArgs args;

  @override
  Widget build(BuildContext context) {
    var group = args.primitive as pg.Group;

    if (group.collapsed) {
      return collapsedContent();
    }

    var props = args.properties as GroupDefaultProperties;

    late Widget content;

    List<pg.Primitive>? modelPrimitives;
    if (args.modelPrimitive != null) {
      var modelGroup = args.modelPrimitive as pg.Group;
      modelPrimitives = modelGroup.groupItems;
    }

    content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignmentForRow(props.horizontalItemAlignment),
      crossAxisAlignment: crossAxisAlignmentForRow(props.verticalItemAlignment),
      textBaseline: TextBaseline.alphabetic,
      children:
          // This is very elegant but we'll see how it performs.  Documentation says
          // stuff in .of method should work in O(1) time with a "small constant".
          // An alternative approach is to pass Embodifier into constructor of each
          // embodiment.
          InheritedEmbodifier.of(context).buildPrimitiveList(
              context,
              group.groupItems,
              modelPrimitives: modelPrimitives,
              horizontalUnbounded: true,
              parentIsFlex: true),
    );

    return encloseWithPBMSAF(
      content,
      args,
      verticalUnbounded: true,
      status: group.status
    );
  }
}
