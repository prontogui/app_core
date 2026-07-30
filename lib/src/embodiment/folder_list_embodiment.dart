// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// All rights reserved. Use of this source code is governed by the
// proprietary license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:dartlib/dartlib.dart' as pg;
import 'package:flutter/material.dart';
import '../embodifier.dart';
import 'embodiment_args.dart';
import 'embodiment_help.dart';
import 'properties.dart';
import 'selection_mixin.dart';

/// A visible entry in the folder list after applying the expand/collapse algorithm.
class _VisibleEntry {
  _VisibleEntry(this.primitive, this.originalIndex, this.level);
  final pg.Primitive primitive;
  final int originalIndex;
  final int level;
}

class FolderListEmbodiment extends StatefulWidget {
  FolderListEmbodiment.fromArgs(this.args, {super.key})
      : list = args.primitive as pg.ListP,
        props = args.properties as ListDefaultProperties;

  final EmbodimentArgs args;
  final ListDefaultProperties props;
  final pg.ListP list;

  @override
  State<FolderListEmbodiment> createState() => _FolderListEmbodimentState();
}

class _FolderListEmbodimentState extends State<FolderListEmbodiment>
    with SelectionModesMixin {
  Embodifier? embodifier;

  void setCurrentSelected(int tapped) {
    setState(() {
      updateSelection(
        widget.list.selectionMode,
        widget.list.selectedItems,
        (List<int> selection) {
          if (!const ListEquality().equals(widget.list.selectedItems, selection)) {
            widget.list.selectedItems = selection;
            widget.list.issueSelectionChanged();
          }
        },
        tapped,
      );
    });
  }

  /// Applies the expand/collapse rendering algorithm from the spec.
  ///
  /// 1. Maintain a variable hideAtOrBelowLevel, initially set to none.
  /// 2. For each item in ListItems, in order:
  ///    a. If hideAtOrBelowLevel is set and item's Level >= hideAtOrBelowLevel, skip.
  ///    b. If hideAtOrBelowLevel is set and item's Level < hideAtOrBelowLevel, clear it.
  ///    c. Render the item at its Level, subject to its own Status field.
  ///    d. If the item is a Folder and Expanded is false, set hideAtOrBelowLevel to Level + 1.
  List<_VisibleEntry> _computeVisibleEntries() {
    var entries = <_VisibleEntry>[];
    int? hideAtOrBelowLevel;

    for (var i = 0; i < widget.list.listItems.length; i++) {
      var item = widget.list.listItems[i];
      int level = 0;

      if (item is pg.Folder) {
        level = item.level;
      } else if (item is pg.FolderItem) {
        level = item.level;
      }

      // Step 2a: skip if hidden by a collapsed folder
      if (hideAtOrBelowLevel != null && level >= hideAtOrBelowLevel) {
        continue;
      }

      // Step 2b: exited the collapsed folder's scope
      if (hideAtOrBelowLevel != null && level < hideAtOrBelowLevel) {
        hideAtOrBelowLevel = null;
      }

      // Step 2c: add to visible entries
      entries.add(_VisibleEntry(item, i, level));

      // Step 2d: if folder is collapsed, hide items below
      if (item is pg.Folder && !item.expanded) {
        hideAtOrBelowLevel = level + 1;
      }
    }

    return entries;
  }

  Widget _buildEntry(BuildContext context, _VisibleEntry entry) {
    var item = entry.primitive;
    var indentation = entry.level * 24.0;

    pg.Primitive? modelPrimitive;
    if (item is pg.Folder) {
      modelPrimitive = widget.list.modelFolder;
    } else if (item is pg.FolderItem) {
      modelPrimitive = widget.list.modelItem;
    }

    Widget content = embodifier!.buildPrimitive(
      context,
      item,
      modelPrimitive: modelPrimitive,
    );

    // Apply indentation based on level
    Widget row = Padding(
      padding: EdgeInsets.only(left: indentation),
      child: content,
    );

    // Handle status for the individual entry
    int status = 0;
    if (item is pg.Folder) {
      status = item.status;
    } else if (item is pg.FolderItem) {
      status = item.status;
    }

    // Apply hidden status (visible but takes space)
    if (status == 2) {
      row = Opacity(
        opacity: 0.0,
        child: IgnorePointer(ignoring: true, child: row),
      );
    }

    // Apply disabled status (visible but grayed out)
    if (status == 1) {
      row = Opacity(
        opacity: 0.5,
        child: IgnorePointer(ignoring: true, child: row),
      );
    }

    // Apply collapsed status (takes no space)
    if (status == 3) {
      return const SizedBox.shrink();
    }

    // Handle selection highlighting for both Folder and FolderItem
    if (widget.list.selectedItems.contains(entry.originalIndex)) {
      row = Container(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        child: row,
      );
    }

    // Make the row tappable for selection
    if (widget.list.selectionMode > 0) {
      row = GestureDetector(
        onTap: () => setCurrentSelected(entry.originalIndex),
        behavior: HitTestBehavior.opaque,
        child: row,
      );
    }

    return row;
  }

  @override
  Widget build(BuildContext context) {
    var list = widget.list;

    if (list.collapsed) {
      return collapsedContent();
    }

    embodifier ??= InheritedEmbodifier.of(context);

    var visibleEntries = _computeVisibleEntries();

    Widget content = ListView.builder(
      itemCount: visibleEntries.length,
      itemBuilder: (context, index) =>
          _buildEntry(context, visibleEntries[index]),
    );

    return encloseWithPBMSAF(
      content,
      widget.args,
      verticalUnbounded: true,
      horizontalUnbounded: true,
      status: list.status,
    );
  }
}
