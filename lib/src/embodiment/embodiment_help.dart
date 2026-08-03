// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:flutter/material.dart';
import 'embodiment_args.dart';
import 'properties.dart' as p;
import 'icon_map.dart';

(double, double, double, double) _effectiveLRTB(
    double? all, double? l, double? r, double? t, double? b) {
  double effL = 0.0, effR = 0.0, effT = 0.0, effB = 0.0;

  if (all != null) {
    effL = all;
    effR = all;
    effT = all;
    effB = all;
  }
  if (l != null) {
    effL = l;
  }
  if (r != null) {
    effR = r;
  }
  if (t != null) {
    effT = t;
  }
  if (b != null) {
    effB = b;
  }
  return (effL, effR, effT, effB);
}

Border _makeBorder(double l, double r, double t, double b, Color? borderColor) {
  Color color = Colors.black;
  if (borderColor != null) {
    color = borderColor;
  }
  int selector = 0;

  if (l > 0.0) {
    selector += 1000;
  }
  if (r > 0.0) {
    selector += 100;
  }
  if (t > 0.0) {
    selector += 10;
  }
  if (b > 0.0) {
    selector += 1;
  }

  // This is absolutely nuts but BorderSide doesn't have null arguments.

  switch (selector) {
    // Case LRTB
    case 0000:
      return const Border();
    case 0001:
      return Border(bottom: BorderSide(width: b, color: color));
    case 0010:
      return Border(
        top: BorderSide(width: t, color: color),
      );
    case 0011:
      return Border(
          top: BorderSide(width: t, color: color),
          bottom: BorderSide(width: b, color: color));
    case 0100:
      return Border(
        right: BorderSide(width: r, color: color),
      );
    case 0101:
      return Border(
          right: BorderSide(width: r, color: color),
          bottom: BorderSide(width: b, color: color));
    case 0110:
      return Border(
        right: BorderSide(width: r, color: color),
        top: BorderSide(width: t, color: color),
      );
    case 0111:
      return Border(
          right: BorderSide(width: r, color: color),
          top: BorderSide(width: t, color: color),
          bottom: BorderSide(width: b, color: color));
    case 1000:
      return Border(
        left: BorderSide(width: l, color: color),
      );
    case 1001:
      return Border(
          left: BorderSide(width: l, color: color),
          bottom: BorderSide(width: b, color: color));
    case 1010:
      return Border(
        left: BorderSide(width: l, color: color),
        top: BorderSide(width: t, color: color),
      );
    case 1011:
      return Border(
          left: BorderSide(width: l, color: color),
          top: BorderSide(width: t, color: color),
          bottom: BorderSide(width: b, color: color));
    case 1100:
      return Border(
        left: BorderSide(width: l, color: color),
        right: BorderSide(width: r, color: color),
      );
    case 1101:
      return Border(
          left: BorderSide(width: l, color: color),
          right: BorderSide(width: r, color: color),
          bottom: BorderSide(width: b, color: color));
    case 1110:
      return Border(
        left: BorderSide(width: l, color: color),
        right: BorderSide(width: r, color: color),
        top: BorderSide(width: t, color: color),
      );
    case 1111:
      return Border(
          left: BorderSide(width: l, color: color),
          right: BorderSide(width: r, color: color),
          top: BorderSide(width: t, color: color),
          bottom: BorderSide(width: b, color: color));
    default:
      return const Border();
  }
}

/// Encloses a widget [content] with additioanl widgets to apply Padding, Border,
/// Margin, fixed Sizing, and Alignment according the the common properties [args.properties].
/// It also encloses the content with Flexible when there are no horizontal or vertical
/// constraints, as specified in embodiment arguments [args].
Widget encloseWithPBMSAF(
  Widget content,
  EmbodimentArgs args,
  {
    bool horizontalUnbounded = false,
    bool verticalUnbounded = false,
    p.CommonPropertyAccess? altProps,
    required int status,
  }
) {
  bool horizontalSized = false;
  bool verticalSized = false;
  late p.CommonPropertyAccess props;
  bool disabled = status >= 1;
  bool hidden = status >= 2;
  
  if (altProps != null) {
    props = altProps;
  } else {
    props = args.properties as p.CommonPropertyAccess;
  }
  
  var isSelectedFunc = args.callbacks?.isSelected;

  // Are any common properties set or is there selectability? Otherwise, we can
  // skip PBMSA altogether.
  if (props.areCommonProps || isSelectedFunc != null) {
    Color? backgroundColor = props.backgroundColor;

    // Apply padding
    if (props.isPadding) {
      var (l, r, t, b) = _effectiveLRTB(props.paddingAll, props.paddingLeft,
          props.paddingRight, props.paddingTop, props.paddingBottom);

      var padding = EdgeInsets.only(left: l, right: r, top: t, bottom: b);

      content = Padding(
        padding: padding,
        child: content,
      );
    }

    // If using a background color then enclose in ColoredBox
    if (backgroundColor != null) {
      content = ColoredBox(
        color: backgroundColor,
        child: content,
      );
    }

    // Apply border
    if (props.isBorder) {
      var (l, r, t, b) = _effectiveLRTB(props.borderAll, props.borderLeft,
          props.borderRight, props.borderTop, props.borderBottom);

      late BoxBorder border;
      var borderColor = props.borderColor;

      border = _makeBorder(l, r, t, b, borderColor);

      content = Container(
          decoration: BoxDecoration(
              // This can be used to set a background color
              //          color: props.backgroundColor,
              border: border),
          //  padding: EdgeInsets.only(left: l, right: r, top: t, bottom: b),
          child: content);
    }

    // Get margin
    EdgeInsetsGeometry? margin;
    if (props.isMargin) {
      var (l, r, t, b) = _effectiveLRTB(props.marginAll, props.marginLeft,
          props.marginRight, props.marginTop, props.marginBottom);

      margin = EdgeInsets.only(left: l, right: r, top: t, bottom: b);
    }

    // Get sizing
    BoxConstraints? sizing;
    if (props.isSizing) {
      sizing =
          BoxConstraints.tightFor(width: props.width, height: props.height);
      horizontalSized = props.width != null;
      verticalSized = props.height != null;
    }

    // If selectable then enclose with a ListTile to show selection and handle taps.
    if (isSelectedFunc != null) {
      var indices = args.callbacks?.indexes;
      if (indices != null) {
        var tapHandler = args.callbacks?.onSelection;
        content = ListTile(
          title: content,
          selected: isSelectedFunc(args.callbacks!.indexes),
          isThreeLine: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 2.0),
          onTap: () {
            if (tapHandler != null) {
              tapHandler(indices);
            }
          },
        );

        // Add sizing if unbounded and no sizing specified in corresponding direction.
        // (Note: ListTile is unbounded in horizontal direction)
        if (args.horizontalUnbounded && !horizontalSized) {
          const double defaultWidth = 100;
          if (sizing == null) {
            sizing = BoxConstraints.tightFor(width: defaultWidth);
          } else {
            sizing = sizing.tighten(width: defaultWidth);
          }
          horizontalSized = true;
        }
      }
    }

    // Apply margin or sizing
    if (margin != null || sizing != null) {
      content = Container(padding: margin, constraints: sizing, child: content);
    }

    // Apply positioning (if allowed by parent)
    if (args.usePositioning) {
      if (props.isPositioning) {
        double? left = props.left;
        double? right = props.right;
        double? top = props.top;
        double? bottom = props.bottom;
        double? width = props.width;
        double? height = props.height;

        // Only two out of three can be set.  left + right takes precedence.
        if (left != null && right != null && width != null) {
          width = null;
        }

        // Only two out of three can be set.  top + bottom takes precedence.
        if (top != null && bottom != null && height != null) {
          height = null;
        }

        content = Positioned(
            left: left,
            right: right,
            width: width,
            top: top,
            bottom: bottom,
            height: height,
            child: content);
      } else {
        double? width = props.width;
        double? height = props.height;
        double? right;
        double? bottom;

        // if no width specified then expand to full width of CCA
        if (width == null) {
          right = 0.0;
        }
        // if no height specified then expand to full height of CCA
        if (height == null) {
          bottom = 0.0;
        }

        content = Positioned(
            left: 0.0,
            width: width,
            right: right,
            top: 0.0,
            height: height,
            bottom: bottom,
            child: content);

        horizontalSized = true;
        verticalSized = true;
      }
    } else {
      // Otherwise, Apply alignment
      var halign = props.horizontalAlignment;
      var valign = props.verticalAlignment;

      if (halign != null || valign != null) {
        content = _applyAlignment(content, halign, valign);
      }
    }
  } // SKIP PBMSA DROPS TO HERE

  if (hidden) {
    // Note: the objective here is to keep the space consumed by the content the same, so other primitives remain
    // unmoved and in place, regardless of whether this content is visible or not. 
    content = IgnorePointer(
      ignoring: true,
      child: ExcludeFocus(
        excluding: true,
        child: Opacity(opacity: 0.0, child: content)),
    );
  } else if (disabled) {
    content = IgnorePointer(
      ignoring: true,
      child: ExcludeFocus(
        excluding: true,
        child: content),
    );
  }

  // Need Flexible widget to deal with unbounded situation?
  var flexibleReason1 =
      (args.horizontalUnbounded && horizontalUnbounded && !horizontalSized);
  var flexibleReason2 =
      (args.verticalUnbounded && verticalUnbounded && !verticalSized);
  var needsFlexible = args.parentIsFlex && (flexibleReason1 || flexibleReason2);

  if (needsFlexible) {
    content = Flexible(child: content);
  }

  return content;
}

Widget _applyAlignment(Widget content, p.HorizontalAlignment? halign, p.VerticalAlignment? valign) {

  double alignX, alignY;
  bool expandX = false;
  bool expandY = false;

  if (halign != null) {
    switch (halign) {
      case p.HorizontalAlignment.left:
        alignX = -1.0;
      case p.HorizontalAlignment.center:
        alignX = 0.0;
      case p.HorizontalAlignment.right:
        alignX = 1.0;
      case p.HorizontalAlignment.expand:
        alignX = 0.0;
        expandX = true;
    }
  } else {
    alignX = 0.0;
  }

  if (valign != null) {
    switch (valign) {
      case p.VerticalAlignment.top:
        alignY = -1.0;
      case p.VerticalAlignment.middle:
        alignY = 0.0;
      case p.VerticalAlignment.bottom:
        alignY = 1.0;
      case p.VerticalAlignment.expand:
        alignY = 0.0;
        expandY = true;
    }
  } else {
    alignY = 0.0;
  }

  if (expandX && expandY) {
    // Note:  this probably isn't needed and can use the content as is
    content = Expanded(child: content);
  } else if (expandX) {
    content = Align(
        alignment: Alignment(alignX, alignY),
        child: SizedBox(
          width: double.infinity,
          child: content,
        ));
  } else if (expandY) {
    content = Align(
        alignment: Alignment(alignX, alignY),
        child: SizedBox(
          height: double.infinity,
          child: content,
        ));
  } else {
    content = Align(
      alignment: Alignment(alignX, alignY),
      child: content,
    );
  }
  
  return content;
}

/// Returns contents that represents a collapsed primitive.
Widget collapsedContent() {
  return const SizedBox.shrink();
}

E2? _convertEnum<E1 extends Enum, E2 extends Enum>(E1 from, List<E2> toEnums) {
  for (var e in toEnums) {
    if (e.name == from.name) {
      return e;
    }
  }
  return null;
}

TextStyle? buildTextStyle(p.Properties props, {TextStyle? defaultStyle}) {
  late FontWeight? fontWeight;

  var textProps = props as p.TextDefaultPropertyAccess;

  switch (textProps.fontWeight) {
    case p.FontWeight.normal:
      fontWeight = FontWeight.normal;
      break;
    case p.FontWeight.bold:
      fontWeight = FontWeight.bold;
      break;
    case p.FontWeight.w1:
      fontWeight = FontWeight.w100;
      break;
    case p.FontWeight.w2:
      fontWeight = FontWeight.w200;
      break;
    case p.FontWeight.w3:
      fontWeight = FontWeight.w300;
      break;
    case p.FontWeight.w4:
      fontWeight = FontWeight.w400;
      break;
    case p.FontWeight.w5:
      fontWeight = FontWeight.w500;
      break;
    case p.FontWeight.w6:
      fontWeight = FontWeight.w600;
      break;
    case p.FontWeight.w7:
      fontWeight = FontWeight.w700;
      break;
    case p.FontWeight.w8:
      fontWeight = FontWeight.w800;
      break;
    case p.FontWeight.w9:
      fontWeight = FontWeight.w900;
      break;
    default:
      fontWeight = null;
  }

  FontStyle? fontStyle;
  var fontStyleProperty = textProps.fontStyle;

  if (fontStyleProperty!= null) {
    fontStyle = _convertEnum<p.FontStyle, FontStyle>(fontStyleProperty, FontStyle.values);
  }

  if (textProps.fontColor != null
    || textProps.fontSize != null
    || textProps.fontFamily != null
    || fontWeight != null
    || fontStyle != null
  ) {
    return TextStyle(
      //backgroundColor: props.backgroundColor,
      color: textProps.fontColor,
      fontSize: textProps.fontSize,
      fontFamily: textProps.fontFamily,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: 1.0, // needed for centering the text vertically
      leadingDistribution: TextLeadingDistribution
          .even, // needed for centering the text vertically
    );
  }

  return defaultStyle;
}

Widget _buildSimpleAlignedText(String text, p.Properties props) {
  late TextAlign textAlign;

  var textProps = props as p.TextDefaultPropertyAccess;

  switch (textProps.horizontalTextAlignment) {
    case p.HorizontalTextAlignment.left:
      textAlign = TextAlign.left;
      break;
    case p.HorizontalTextAlignment.center:
      textAlign = TextAlign.center;
      break;
    case p.HorizontalTextAlignment.right:
      textAlign = TextAlign.right;
      break;
    case p.HorizontalTextAlignment.justify:
      textAlign = TextAlign.justify;
      break;
  }

  return Text(
    text,
    style: buildTextStyle(props),
    textAlign: textAlign,
  );
}

Widget buildStyledText(String text, p.Properties props, {bool simpleAlignment = false}) {

  var textProps = props as p.TextDefaultPropertyAccess;
  var commonProps = props as p.CommonPropertyAccess;

  if (simpleAlignment) {
    return _buildSimpleAlignedText(text, props);
  }

  TextAlign? textAlign;
  late double alignY;
  late double alignX;
  bool alignNeeded = false;

  if (commonProps.width != null || commonProps.height != null) {
    alignNeeded = true;

    switch (textProps.horizontalTextAlignment) {
      case p.HorizontalTextAlignment.left:
        alignX = -1.0;
        textAlign = TextAlign.left;
        break;
      case p.HorizontalTextAlignment.center:
        alignX = 0.0;
        textAlign = TextAlign.center;
        break;
      case p.HorizontalTextAlignment.right:
        alignX = 1.0;
        textAlign = TextAlign.right;
        break;
      case p.HorizontalTextAlignment.justify:
      // THIS PROBABLY DOESN'T WORK. NEED TO EXPAND IN THE X DIRECTION TO FILL THE SPECIFIED WIDTH....
        alignX = 0.0;
        textAlign = TextAlign.justify;
        break;
    }

    switch (textProps.verticalTextAlignment) {
      case p.VerticalTextAlignment.top:
        alignY = -1.0;
        break;
      case p.VerticalTextAlignment.middle:
        alignY = 0.0;
        break;
      case p.VerticalTextAlignment.bottom:
        alignY = 1.0;
        break;
    }
  }

  Widget content = Text(
      text,
      style: buildTextStyle(props),
      textAlign: textAlign,
    );

  if (alignNeeded) {
    content = Align(
      alignment: Alignment(alignX, alignY),
      child: content,
    );
  }

  return content;
}

String colorToHexValue(Color color) {
  
  // Converts a single component from double to hex string
  String component(double component) => ((component * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0').toUpperCase();

  // Converts all component into a single hex value string
  return '#${component(color.a)}${component(color.r)}${component(color.g)}${component(color.b)}';
}

Widget errorWidget() {
  return Icon(translateIdToIconData('error'),
  color: Colors.red, size: 25);
}
