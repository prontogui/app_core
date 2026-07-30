//import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

import 'package:flutter/services.dart';

mixin SelectionModesMixin {

  // First index selected, for range selection with the Shift key.
  int firstPress = 0;

  void updateSelection(int selectionMode, List<int> curSelection, Function(List<int> newSelection) setter, int newSelected) {
      
      void handleRangeSelection(bool isShift) {
        if (!isShift) {
          setter([newSelected]);
          firstPress = newSelected;
        } else if (curSelection.isEmpty) {
          setter([newSelected]);
        } else {
          int from, to;

          if (newSelected <= firstPress) {
            from = newSelected;
            to = firstPress;
          } else {
            from = firstPress;
            to = newSelected;
          }

          var selection = List<int>.generate(to - from + 1, (i) => from + i, growable: false);
          setter(selection);
        }
      }

      // Depending on the selection mode...
      switch (selectionMode) {
      // None
      case 0:
        setter(const []);

      // Single - one always
      case 1:
        setter([newSelected]);

      // Single - one or none
      case 2:
        if (curSelection.isEmpty || !curSelection.contains(newSelected)) {
          setter([newSelected]);
        } else {
          setter(const []);
        }

      // Multiple
      case 3:
        var selection = List<int>.from(curSelection);
        if (selection.contains(newSelected)) {
          selection.remove(newSelected);
        } else {
          selection.add(newSelected);
          selection.sort((a, b) => a - b);
        }
        setter(selection);

      // Range - always atleast one
      case 4:
        handleRangeSelection(HardwareKeyboard.instance.isShiftPressed);

      // Range - any contiguous or none
      case 5:
        var isShift = HardwareKeyboard.instance.isShiftPressed;

        if (!isShift && curSelection.length == 1 && curSelection[0] == newSelected) {
          setter(const []);
          break;
        }
        handleRangeSelection(isShift);
      }
  }

  void updateSelectAll(int selectionMode, List<int> curSelection, int len, Function(List<int> newSelection) setter, bool? all) {
      
      void selectAll() {
        var selection = List<int>.generate(len, (i) => i, growable: false);
        setter(selection);
      }

      if (all == null) {
        return;
      }

      // Depending on the selection mode...
      switch (selectionMode) {
      // None
      case 0:
        setter(const []);

      // Single - one always
      case 1:
        if (!all) {
          setter(const []);
        } else if (curSelection.isNotEmpty) {
          setter([curSelection[0]]);
        } else {
          setter([0]);
        }

      // Single - one or none
      case 2:
        if (!all) {
          setter(const []);
        } else if (curSelection.isNotEmpty) {
          setter([curSelection[0]]);
        }

      // Multiple, or Range - contiguous or none
      case 3:
      case 5:
        if (!all) {
          setter(const []);
        } else {
          selectAll();
        }

      // Range - always atleast one
      case 4:
        if (!all) {
          if (curSelection.isNotEmpty) {
            setter([curSelection[0]]);
          } else {
            setter(const []);
          }
        } else {
          selectAll();
        }
      }
  }

}
