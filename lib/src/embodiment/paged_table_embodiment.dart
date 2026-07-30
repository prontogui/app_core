// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// All rights reserved. Use of this source code is governed by the
// proprietary license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:dartlib/dartlib.dart' as pg;
import 'package:dartlib/log.dart';
import '../embodifier.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'embodiment_args.dart';
import 'embodiment_help.dart';
import 'properties.dart';
import 'selection_mixin.dart';
import 'package:intl/intl.dart';

class PagedTableEmbodiment extends StatefulWidget {
  PagedTableEmbodiment.fromArgs(this.args, {super.key})
    : table = args.primitive as pg.Table,
    props = args.properties as TablePagedProperties;

  final EmbodimentArgs args;
  final TablePagedPropertyAccess props;
  final pg.Table table;

  @override
  State<PagedTableEmbodiment> createState() => _PagedTableEmbodimentState();
}

class _SortingException {
}

class _PagedTableEmbodimentState extends State<PagedTableEmbodiment> with SelectionModesMixin {

  void setCurrentSelected(int tapped) {
    // Is table disabled status?
    if (widget.table.status != 0) {
      return;
    }

    setState(() {
        updateSelection(
          widget.table.selectionMode,
          widget.table.selectedRows,
          (List<int> selection) {
            // Has selection changed?
            if (!ListEquality().equals(widget.table.selectedRows, selection)) {
              widget.table.selectedRows = selection;
              widget.table.issueSelectionChanged();
            }
          },
        tapped);
      });
  }

  void handleSelectAll(bool? all) {
    // Is table disabled status?
    if (widget.table.status != 0) {
      return;
    }

    setState(() {
      updateSelectAll(
        widget.table.selectionMode,
        widget.table.selectedRows,
        widget.table.rows.length,
        (List<int> selection) => widget.table.selectedRows = selection,
        all
      );
    });
  }

  // Translates natural row index from table.rows (list index) to visual row index (value of list element).
  List<int>? _fwdOrdering;

  // Maps visual row index to natural table row index.
  int v2n(int index) {
    if (_fwdOrdering == null) {
      return index;
    }
    return _fwdOrdering![index];
  }

  // Current column being sorted
  late int _sortColumn;

  // Direction of current column being sorted
  late bool _sortAscending;

  SortType getColumnSortType(int columnIndex) {

    var columnSettings = widget.props.columnSettings;

    if (columnIndex >= columnSettings.length) {
      return SortType.none;
    }

    return columnSettings[columnIndex].sortType ?? SortType.none;
  }

  DateFormat? getDateTimeFormat(int columnIndex) {
    var columnSettings = widget.props.columnSettings;

    if (columnIndex < 0 || columnIndex >= columnSettings.length) {
      return null;
    }

    var dateTimeFormat = columnSettings[columnIndex].dateTimeFormat;

    if (dateTimeFormat == null) {
      return null;
    }

    return DateFormat(dateTimeFormat);
  }

  bool canSortColumn(int columnIndex) {

    var table = widget.table;

    return columnIndex >= 0
      && columnIndex < table.headerRow.length
      && getColumnSortType(columnIndex) != SortType.none
      && table.status != 2;
  }

  void sortTableRows(int columnIndex, bool ascending) {
    
    var table = widget.table;
    var rows = widget.table.rows;

    // All the reasons why we can't do sorting...
    if (!canSortColumn(columnIndex) || table.status == 2) {
      _fwdOrdering = null;
      _sortColumn = -1;
      _sortAscending = true;
      return;
    }

    _sortColumn = columnIndex;
    _sortAscending = ascending;

    // The function to use for comparing elements
    int Function(String, String) sortComparison;

    // Get column-specific sorting settings
    var sortType = getColumnSortType(columnIndex);
    var dateTimeFormat = getDateTimeFormat(columnIndex);

    // Construct the correct comparison function for sorting
    switch (sortType) {
    case SortType.none:    
    case SortType.text:
    case SortType.tag:
      sortComparison = (a, b) => a.compareTo(b);
    case SortType.numeric:
      sortComparison = (a, b) {
        try {
          double da = double.parse(a);
          double db = double.parse(b);
          return da.compareTo(db);
        }
        catch (_) {
          throw _SortingException();
        }
      };
    
    case SortType.dateTime:
      if (dateTimeFormat == null) {
        logger.w('table "paged" embodiment: dateTimeFormat was not specified in columnSettings property; defaulting to regular text comparison');
        // Default to regular text comparison
        sortComparison = (a, b) => a.compareTo(b);
        break;
      }

      sortComparison = (a, b) {
        try {
          var da = dateTimeFormat.parse(a);
          var db = dateTimeFormat.parse(b);
          return da.compareTo(db);
        }
        catch (_) {
          // End the sort by throwing an exception
          throw _SortingException();
        }
      };
    }

    List<(int, String)> sortlist;

    if (sortType == SortType.tag) {
      sortlist = List<(int, String)>.generate(rows.length, (i) => (i, rows[i][columnIndex].tag), growable: false);
    } else {
      sortlist = List<(int, String)>.generate(rows.length, (i) => (i, rows[i][columnIndex].toString()), growable: false);
    }

    try {
      if (ascending) {
        sortlist.sort((a, b) => sortComparison(a.$2, b.$2));
      } else {
        sortlist.sort((a, b) => sortComparison(b.$2, a.$2));
      }
    } on _SortingException {
      logger.e('table "paged" embodiment: an error occurred trying to sort column; perhaps an invalid dateTimeFormat was specified; defaulting to natural order of rows');

      // Just use natural order
      _fwdOrdering = List<int>.generate(rows.length, (i) => i, growable: false);
      return;
    }
    _fwdOrdering = List<int>.generate(sortlist.length, (i) => sortlist[i].$1, growable: false);
  }

  void handleOnSort(int columnIndex, bool ascending) {
    // Is table disabled status?
    if (widget.table.status != 0) {
      return;
    }

    setState(() {
      sortTableRows(columnIndex, ascending);
    });
  }

  @override
  void initState() {
    super.initState();
    sortTableRows(-1, true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    // Try to sort rows the same as last time
    if (canSortColumn(_sortColumn)) {
      sortTableRows(_sortColumn, _sortAscending);
    } else {
      sortTableRows(-1, true);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var table = widget.table;
    var props = widget.props;

    if (table.collapsed) {
      return collapsedContent();
    }

    bool selectionEnabled = widget.table.selectionMode > 0;

    // Figure out how max # columns to display from headings and length of first row
    int totalNumColumns = table.headerRow.length;
    if (table.rows.isNotEmpty) {
      totalNumColumns = max(totalNumColumns, table.rows[0].length);
    }

    // Handle the case where table has an empty template row.
    if (totalNumColumns == 0) {
      logger.e('table "paged" embodiment: no columns are defined in the header row or the table data');
      return errorWidget();
    }
    // Build the column configurations and a "fingerprint" of the headers
    var headerFingerprint = "";
    var columnsD = List<DataColumn>.empty(growable: true);

    var embodifier = InheritedEmbodifier.of(context);

    Function(int columnIndex, bool ascending)? determineOnSort(int columnIndex) {
      if (canSortColumn(columnIndex)) {
          return handleOnSort;
        }
        return null;
    }

    for (int col = 0; col < table.headings.length; col++) {
      var heading = table.headings[col];
      headerFingerprint = "$headerFingerprint|$heading";

      TableColumnWidth? columnWidth;

      if (col < props.columnSettings.length) {
        var columnSettings = props.columnSettings[col];

        var width = columnSettings.width;
        if (width != null) {
          columnWidth = FixedColumnWidth(width);
        }
      }

      var headingEmbodiment = embodifier.buildPrimitive(context, table.headerRow[col]);

      columnsD.add(DataColumn(
        label: Expanded(child: headingEmbodiment,),
        columnWidth: columnWidth,
//        headingRowAlignment: MainAxisAlignment.center
        onSort: determineOnSort(col),
      ));
    }

    // Add additional headings to if needed to reach total num. columns
    for (int i = columnsD.length; i < totalNumColumns; i++) {
      columnsD.add(const DataColumn(
        label: Text(''),
      ));
    }

    // Build the data rows from primitive rows
    var rowsD = List<DataRow>.empty(growable: true);
    var modelRow = table.modelRow;
    int numRows = table.rows.length;

    for (var visualRowIndex = 0; visualRowIndex < numRows; visualRowIndex++) {
      var cellsD = List<DataCell>.empty(growable: true);

      var row = table.rows[v2n(visualRowIndex)];

      int col = 0;
      for (var cell in row) {
        pg.Primitive? modelPrimitive;

        // Is there a corresponding model primitive for the column?
        if (col < modelRow.length) {
          modelPrimitive = modelRow[col];
        }

        // Build the embodiment for the cell, incorporating any model primitive properties.
        var cellEmbodiment = embodifier.buildPrimitive(context, cell,
            modelPrimitive: modelPrimitive);

        cellsD.add(DataCell(cellEmbodiment));

        col++;
      }

      if (selectionEnabled) {
        var naturalRowIndex = v2n(visualRowIndex);

        rowsD.add(
          DataRow(
            cells: cellsD,
            selected: table.selectedRows.contains(naturalRowIndex),
            onSelectChanged: (value) => setCurrentSelected(naturalRowIndex),
          )
      );
      } else {
        rowsD.add(
          DataRow(
            cells: cellsD,
          )
        );
      }
    }

    var ds = TableDataSource(rowsD, widget.table.selectedRows.length);

    // Construct a paginated data table and use a key. The key is neededed because
    // the state of which page the user is viewing will get reset in certain rebuild scenarios.
    //
    // NOTE: more thought should be put into generating an appropriate key for the table, due to the
    // dynamic nature of building user interfaces. For now, we'll use the fingerprint of the header
    // titles to form a key.
    var content = PaginatedDataTable(
        rowsPerPage: props.rowsPerPage,
        columns: columnsD,
        source: ds,
        key: Key(headerFingerprint),
        onSelectAll: selectionEnabled ? (value) => handleSelectAll(value) : null,
        showCheckboxColumn: selectionEnabled,
        sortColumnIndex: _sortColumn >= 0 ? _sortColumn : null,
        sortAscending: _sortAscending,
        showFirstLastButtons: widget.props.showFirstLastButtons,
        );
        
    return encloseWithPBMSAF(
      content,
      widget.args,
      horizontalUnbounded: true,
      status: table.status
    );
  }
}

class TableDataSource extends DataTableSource {
  TableDataSource(this.rows, this.selectedRowCount);

  final List<DataRow> rows;

  @override
  final int selectedRowCount;

  @override
  int get rowCount => rows.length;

  @override
  DataRow? getRow(int index) {
    if (index < rows.length) {
      return rows[index];
    }
    return null;
  }

  @override
  bool get isRowCountApproximate => false;
}
