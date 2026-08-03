// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:collection/collection.dart';
import 'package:dartlib/dartlib.dart' as pg;
import '../embodifier.dart';
import 'package:flutter/material.dart';
import 'embodiment_manifest.dart';
import 'tabbed_list_embodiment.dart';
import 'folder_list_embodiment.dart';
import 'embodiment_args.dart';
import 'embodiment_help.dart';
import 'properties.dart';
import 'selection_mixin.dart';

EmbodimentPackageManifest getManifest() {
  return EmbodimentPackageManifest('List', [
    EmbodimentManifestEntry('default', ListDefaultEmbodiment.fromArgs,
        ListDefaultProperties.fromMap),
    EmbodimentManifestEntry(
        'tabbed', TabbedListEmbodiment.fromArgs, ListTabbedProperties.fromMap),
    EmbodimentManifestEntry('folder-list', FolderListEmbodiment.fromArgs,
        ListDefaultProperties.fromMap),
  ]);
}

enum ListStyle { card, property, normal, tabbed }

class ListDefaultEmbodiment extends StatefulWidget {
  ListDefaultEmbodiment.fromArgs(this.args, {super.key})
      : list = args.primitive as pg.ListP,
        props = args.properties as ListDefaultProperties,
        style = ListStyle.normal;

  final EmbodimentArgs args;
  final ListDefaultProperties props;
  final pg.ListP list;
  final ListStyle style;

  @override
  State<ListDefaultEmbodiment> createState() {
    return _ListDefaultEmbodimentState();
  }
}

class _ListDefaultEmbodimentState extends State<ListDefaultEmbodiment> with SelectionModesMixin {
  Embodifier? embodifier;
  Map<String, dynamic>? modelProperties;

  void setCurrentSelected(int tapped) {
    setState(() {
        updateSelection(
          widget.list.selectionMode,
          widget.list.selectedItems,
          (List<int> selection) {
            // Has selection changed?
            if (!ListEquality().equals(widget.list.selectedItems, selection)) {
              widget.list.selectedItems = selection;
              widget.list.issueSelectionChanged();
            }
          },
        tapped);
      });
  }

  Widget? builder(BuildContext context, int index) {
    var item = widget.list.listItems[index];

    Widget content = embodifier!.buildPrimitive(
      context,
      item,
      modelPrimitive: widget.list.modelItem,
      horizontalUnbounded: widget.props.horizontal,
    );

    // Apply selection highlight
    if (widget.list.selectedItems.contains(index)) {
      content = Container(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        child: content,
      );
    }

    // Make tappable for selection
    if (widget.list.selectionMode > 0) {
      content = GestureDetector(
        onTap: () => setCurrentSelected(index),
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {

    var list = widget.list;

    if (list.collapsed) {
      return collapsedContent();
    }

    // Grab the embodifier for other functions in the class to use.
    embodifier ??= InheritedEmbodifier.of(context);

    var horizontal = widget.props.horizontal;
    var scrollDirection = horizontal ? Axis.horizontal : Axis.vertical;

    Widget content;

    content = ListView.builder(
      itemCount: list.listItems.length,
      itemBuilder: builder,
      scrollDirection: scrollDirection,
    );

    return encloseWithPBMSAF(
      content,
      widget.args,
      verticalUnbounded: true,
      horizontalUnbounded: !horizontal,
      status: list.status
    );
  }
}
