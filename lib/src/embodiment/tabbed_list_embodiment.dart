// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'embodiment_help.dart';
import 'package:dartlib/dartlib.dart' as pg;
import 'package:dartlib/log.dart';
import '../embodifier.dart';
import 'package:flutter/material.dart';
import 'icon_map.dart';
import 'embodiment_args.dart';
import 'properties.dart';

class TabbedListEmbodiment extends StatelessWidget {
  const TabbedListEmbodiment.fromArgs(
    this.args, {
    super.key,
  });

  final EmbodimentArgs args;

  Widget embodifySingleItem(BuildContext context, Embodifier embodifier,
      pg.Primitive item, String parentWidgetType, int itemIndex) {
    // Only certain primitives are supported
    if (item is! pg.Text &&
        item is! pg.Command &&
        item is! pg.Check &&
        item is! pg.Choice &&
        item is! pg.NumericField) {

      logger.e('list "tabbed" embodiment: the frame icon primitive for item $itemIndex is of type "${item.describeType}" which is not supported');
      return errorWidget();
    }

    return embodifier.buildPrimitive(context, item);
  }

  @override
  Widget build(BuildContext context) {
    var list = args.primitive as pg.ListP;

    if (list.collapsed) {
      return collapsedContent();
    }

    var props = args.properties as ListTabbedProperties;

    // Grab the embodifier for other functions in the class to use.
    var embodifier = InheritedEmbodifier.of(context);

    var listItems = list.listItems;

    // Verify that list contains only Frame primitives
    if (listItems.indexWhere((p) => p.describeType != 'Frame') != -1) {
      logger.e('list "tabbed" embodiment: the list contains primitives that are not Frames - only Frames are supported');
      return errorWidget();
    }

    // Build the tabs based on frame's icon and title fields.
    var tabs = List<Tab>.generate(listItems.length, (i) {
      var item = listItems[i];
      assert(item is pg.Frame);
      var frame = item as pg.Frame;

      // If being used, embodify the icon primitive into the Tab.
      if (frame.icon != null) {
        var p = frame.icon as pg.Primitive;
        if (p.describeType == 'Icon') {
          var iconPrimitive = p as pg.Icon;
          return Tab(
            text: frame.title,
            icon: Icon(translateIdToIconData(iconPrimitive.iconID)),
          );
        } else {
          return Tab(
              text: frame.title,
              child: embodifySingleItem(context, embodifier, p, 'Column', i));
        }
      }
      return Tab(text: frame.title);
    });

    var tabViews = List<Widget>.generate(listItems.length, (i) {
      return embodifier.buildPrimitive(context, listItems[i]);
    });

    var tabHeight = props.tabHeight;
    var animationPeriod = Duration(milliseconds: props.animationPeriod);

    var content = DefaultTabController(
        length: tabs.length,
        animationDuration: animationPeriod,
        child: Column(
          children: [
            SizedBox(
              height: tabHeight,
              child: TabBar(
                tabs: tabs,
              ),
            ),
            Expanded(child: TabBarView(children: tabViews))
          ],
        ));
    return encloseWithPBMSAF(
      content,
      args,
      verticalUnbounded: true,
      status: list.status
    );
  }
}
