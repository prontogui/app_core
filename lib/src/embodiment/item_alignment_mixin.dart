// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.


import 'package:flutter/material.dart';
import 'properties.dart';

mixin ItemAlignmentMixin {

  MainAxisAlignment mainAxisAlignmentForRow(HorizontalItemAlignment hAlignment) {
    switch (hAlignment) {
      case HorizontalItemAlignment.left:
        return MainAxisAlignment.start;
      case HorizontalItemAlignment.center:
        return MainAxisAlignment.center;
      case HorizontalItemAlignment.right:
        return MainAxisAlignment.end;
      case HorizontalItemAlignment.expand:
        // expand doesn't apply in this context, just use default of start
        return MainAxisAlignment.start;
      case HorizontalItemAlignment.baseline:
        // baseline doesn't apply in this context, just use default of start
        return MainAxisAlignment.start;
      case HorizontalItemAlignment.spaceBetween:
        return MainAxisAlignment.spaceBetween;
      case HorizontalItemAlignment.spaceAround:
        return MainAxisAlignment.spaceAround;
      case HorizontalItemAlignment.spaceEvenly:
        return MainAxisAlignment.spaceEvenly;
    }
  }

  CrossAxisAlignment crossAxisAlignmentForRow(VerticalItemAlignment vAlignment) {
    switch (vAlignment) {
      case VerticalItemAlignment.top:
        return CrossAxisAlignment.start;
      case VerticalItemAlignment.middle:
        return CrossAxisAlignment.center;
      case VerticalItemAlignment.bottom:
        return CrossAxisAlignment.end;
      case VerticalItemAlignment.expand:
        return CrossAxisAlignment.stretch;
      case VerticalItemAlignment.baseline:
        return CrossAxisAlignment.baseline;
      case VerticalItemAlignment.spaceBetween:
        // spaceBetween doesn't apply in this context, just use default of start
        return CrossAxisAlignment.start;
      case VerticalItemAlignment.spaceAround:
        // spaceAround doesn't apply in this context, just use default of start
        return CrossAxisAlignment.start;
      case VerticalItemAlignment.spaceEvenly:
        // spaceEvenly doesn't apply in this context, just use default of start
        return CrossAxisAlignment.start;
    }
  }

  MainAxisAlignment mainAxisAlignmentForColumn(VerticalItemAlignment vAlignment) {
    switch (vAlignment) {
      case VerticalItemAlignment.top:
        return MainAxisAlignment.start;
      case VerticalItemAlignment.middle:
        return MainAxisAlignment.center;
      case VerticalItemAlignment.bottom:
        return MainAxisAlignment.end;
      case VerticalItemAlignment.expand:
        // expand doesn't apply in this context, just use default of start
        return MainAxisAlignment.start;
      case VerticalItemAlignment.baseline:
        // baseline doesn't apply in this context, just use default of start
        return MainAxisAlignment.start;
      case VerticalItemAlignment.spaceBetween:
        return MainAxisAlignment.spaceBetween;
      case VerticalItemAlignment.spaceAround:
        return MainAxisAlignment.spaceAround;
      case VerticalItemAlignment.spaceEvenly:
        return MainAxisAlignment.spaceEvenly;
    }
  }

  CrossAxisAlignment crossAxisAlignmentForColumn(HorizontalItemAlignment hAlignment) {
    switch (hAlignment) {
      case HorizontalItemAlignment.left:
        return CrossAxisAlignment.start;
      case HorizontalItemAlignment.center:
        return CrossAxisAlignment.center;
      case HorizontalItemAlignment.right:
        return CrossAxisAlignment.end;
      case HorizontalItemAlignment.expand:
        return CrossAxisAlignment.stretch;
      case HorizontalItemAlignment.baseline:
        return CrossAxisAlignment.baseline;
      case HorizontalItemAlignment.spaceBetween:
        // spaceBetween doesn't apply in this context, just use default of start
        return CrossAxisAlignment.start;
      case HorizontalItemAlignment.spaceAround:
        // spaceAround doesn't apply in this context, just use default of start
        return CrossAxisAlignment.start;
      case HorizontalItemAlignment.spaceEvenly:
        // spaceEvenly doesn't apply in this context, just use default of start
        return CrossAxisAlignment.start;
    }
  }
}
