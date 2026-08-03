// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.


import 'package:flutter/material.dart';
import 'package:dartlib/dartlib.dart' as pg;
import 'package:dartlib/log.dart';
import '../embodifier.dart';
import 'properties.dart';
import 'embodiment_help.dart';
import 'embodiment_args.dart';

mixin LabelAndLabelItem {

  // Builds Checkbox-based embodiment with label content.
  Widget buildCheckboxWithLabelContent(
    BuildContext context, Embodifier embodifier, EmbodimentArgs args, String label, pg.Primitive? labelItem, LabelItemPosition labelItemPosition, String callerDesc,
      {
        Function()? onTap,
        Widget? checkbox,
        CommonPropertyAccess? altProps,
        CheckBoxPosition checkBoxPosition = CheckBoxPosition.left,
        bool skipEnclosure = false,
        int status = 0 // default to visible
      }) {

    // Does the labelItem come first? 
    bool itemIsFirst = (labelItemPosition == LabelItemPosition.left || labelItemPosition == LabelItemPosition.top);

    // Make a list of label elements of size 0, 1, or 2, depending on what's specified.
    List<Widget> itemElements = [];

    if (labelItem != null && itemIsFirst) {
      itemElements.add(embodifyLabelItem(context, embodifier, labelItem, callerDesc));
    }

    if (label.isNotEmpty) {
      var styledText = buildStyledText(label, args.properties);
      itemElements.add(styledText);
    }

    if (labelItem != null && !itemIsFirst) {
      itemElements.add(embodifyLabelItem(context, embodifier, labelItem, callerDesc));
    }

    // Trivial case where just a checkbox by itself with no associated item?
    if (itemElements.isEmpty) {
      if (checkbox != null) {
        return encloseWithPBMSAF(checkbox, args, status: status);
      } else {
        return SizedBox.shrink();
      }
    }

    late Widget itemContent;
    var verticalUnbounded = false;
    var horizontalUnbounded = false;

    if (itemElements.length == 1) {
      itemContent = GestureDetector(onTap: onTap, child: itemElements[0]);
    } else {
      // Which way do item elements flow?
      bool flowsVertical = (labelItemPosition == LabelItemPosition.top || labelItemPosition == LabelItemPosition.bottom);

      if (flowsVertical) {
        horizontalUnbounded = true;

        itemContent = Column(mainAxisSize: MainAxisSize.min, children: itemElements,);

        if (onTap != null) {
          itemContent = GestureDetector(onTap: onTap, child: itemContent);
        }

        // Note: for some reason, it expands to biggest vertical space possible when labelItem is an Image. The 
        // following is a work-around. This behavior doesn't happen then labelItem is null, Text, or Icon.
        itemContent = FittedBox(fit: BoxFit.fitWidth, child: itemContent);

      } else {
        verticalUnbounded = true;

        itemContent = Row(mainAxisSize: MainAxisSize.min, children: itemElements,);

        if (onTap != null) {
          itemContent = GestureDetector(onTap: onTap, child: itemContent);
        }

        // Note: for some reason, it expands to biggest vertical space possible when labelItem is an Image. The 
        // following is a work-around. This behavior doesn't happen then labelItem is null, Text, or Icon.
        itemContent = FittedBox(fit: BoxFit.fitHeight, child: itemContent);
      }
    }

    late Widget content;

    if (checkbox != null) {
      switch (checkBoxPosition) {
        case CheckBoxPosition.top:
          horizontalUnbounded = true;
          content = Column(mainAxisSize: MainAxisSize.min, children: [checkbox, itemContent]);
        case CheckBoxPosition.bottom:
          horizontalUnbounded = true;
          content = Column(mainAxisSize: MainAxisSize.min, children: [itemContent, checkbox]);
        case CheckBoxPosition.left:
          verticalUnbounded = true;
          content = Row(mainAxisSize: MainAxisSize.min, children: [checkbox, itemContent]);
        case CheckBoxPosition.right:
          verticalUnbounded = true;
          content = Row(mainAxisSize: MainAxisSize.min, children: [itemContent, checkbox]);
      }
    } else {
      content = itemContent;
    }

    if (skipEnclosure) {
      // TODO: Need to handled hidden status??
      return content;
    }

    return encloseWithPBMSAF(
      content,
      args,
      verticalUnbounded: verticalUnbounded,
      horizontalUnbounded: horizontalUnbounded,
      altProps: altProps,
      status: status
    );
  }

  // The allowed primitives for the label item
  static const Set<String> _allowedTypesForLabelItem = {
    'Icon',
    'Image',
    'Text'
  };

  Widget embodifyLabelItem(BuildContext context, Embodifier embodifier, pg.Primitive item, String callerDesc) {

    // Only certain primitives are supported
    if (!_allowedTypesForLabelItem.contains(item.describeType)) {
      logger.e('$callerDesc: the label item is of type "${item.describeType}" which is not supported');
      return errorWidget();
    }

    return embodifier.buildPrimitive(context, item);
  }

}