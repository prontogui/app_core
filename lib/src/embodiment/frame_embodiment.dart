// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:app_core/src/embodiment/embodiment_help.dart';

import '../embodifier.dart';
import 'package:dartlib/dartlib.dart' as pg;
import 'package:flutter/material.dart';
import 'embodiment_manifest.dart';
import 'embodiment_args.dart';
import 'snackbar_embodiment.dart';
import 'properties.dart';
import 'item_alignment_mixin.dart';

EmbodimentPackageManifest getManifest() {
  return EmbodimentPackageManifest('Frame', [
    EmbodimentManifestEntry(
        'default', FrameEmbodiment.fromArgs, FrameDefaultProperties.fromMap),
    EmbodimentManifestEntry(
        'full-view', FrameEmbodiment.fromArgs, FrameDefaultProperties.fromMap),
    EmbodimentManifestEntry('dialog-view', FrameEmbodiment.fromArgs,
        FrameDefaultProperties.fromMap),
    EmbodimentManifestEntry('snackbar', SnackBarEmbodiment.fromArgs,
        FrameSnackbarProperties.fromMap)
  ]);
}

class FrameEmbodiment extends StatelessWidget with ItemAlignmentMixin {
  FrameEmbodiment.fromArgs(this.args, {super.key})
      : frame = args.primitive as pg.Frame;

  final EmbodimentArgs args;
  final pg.Frame frame;

  // Note:  when getting around to implementing a manual layout method, take a look
  // at PositionedDirectional class and Positioned widget.

  Widget buildFlowLayout(BuildContext context, FrameDefaultProperties props) {
    late Widget content;
    bool verticalUnbounded = false;
    bool horizontalUnbounded = false;

    switch (props.flowDirection) {
      case FlowDirection.leftToRight:
        content = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: mainAxisAlignmentForRow(props.horizontalItemAlignment),
          crossAxisAlignment: crossAxisAlignmentForRow(props.verticalItemAlignment),
          textBaseline: TextBaseline.alphabetic,
          children: InheritedEmbodifier.of(context).buildPrimitiveList(
              context, frame.frameItems,
              horizontalUnbounded: true,
              parentIsFlex: true),
        );
        verticalUnbounded = true;

      case FlowDirection.topToBottom:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: mainAxisAlignmentForColumn(props.verticalItemAlignment),
          crossAxisAlignment: crossAxisAlignmentForColumn(props.horizontalItemAlignment),
          textBaseline: TextBaseline.alphabetic,
          children: InheritedEmbodifier.of(context).buildPrimitiveList(
              context, frame.frameItems,
              verticalUnbounded: true,
              parentIsFlex: true),
        );
        horizontalUnbounded = true;
    }

    content = encloseWithPBMSAF(
      content,
      args,
      horizontalUnbounded: horizontalUnbounded,
      verticalUnbounded: verticalUnbounded,
      status: frame.status
    );

    return content;
  }

  Widget buildPositionedLayout(BuildContext context) {
    late Widget content;

    content = Stack(
        children: InheritedEmbodifier.of(context).buildPrimitiveList(
            context, frame.frameItems,
            allowPositioned: true));

    content = encloseWithPBMSAF(
      content,
      args,
      horizontalUnbounded: true,
      verticalUnbounded: true,
      status: frame.status
    );

    return content;
  }

  @override
  Widget build(BuildContext context) {

    if (frame.collapsed) {
      return collapsedContent();
    }

    var props = args.properties as FrameDefaultProperties;

    late Widget content;
    switch (props.layoutMethod) {
      case LayoutMethod.flow:
        content = buildFlowLayout(context, props);
      case LayoutMethod.positioned:
        content = buildPositionedLayout(context);
    }

    // Is it a top-level primitive (i.e., a view)?
    if (args.parentIsTopView) {
      content = Scaffold(
        body: content,
      );
    }

    return content;
  }
}
