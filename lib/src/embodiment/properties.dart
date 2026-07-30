import 'package:app_core/src/embodiment/property_help.dart';
import 'package:dartlib/log.dart';
import 'package:flutter/material.dart';

// -------------------------------------
// S U P P O R T   F U N C T I O N S
// -------------------------------------

Color? _getColorTN(Map<String, dynamic>? propertyMap, String propertyName) {
  if (propertyMap == null) {
    // Return default
    return null;
  }
  var cacheItem = propertyMap[propertyName];
  if (cacheItem == null) {
    // Return default
    return null;
  }
  if (cacheItem is! Color) {
    logger.e('property "$propertyName" expected Color but got ${cacheItem.runtimeType}');
    return null;
  }
  return cacheItem;
}

double? _getDoubleTN(Map<String, dynamic>? propertyMap, String propertyName) {
  if (propertyMap == null) {
    // Return default
    return null;
  }
  var cacheItem = propertyMap[propertyName];
  if (cacheItem == null) {
    // Return default
    return null;
  }
  if (cacheItem is! double) {
    logger.e('property "$propertyName" expected double but got ${cacheItem.runtimeType}');
    return null;
  }
  return cacheItem;
}

bool _getYesNoT(
    Map<String, dynamic>? propertyMap, String propertyName, bool defaultValue) {
  if (propertyMap == null) {
    // Return default
    return defaultValue;
  }
  var cacheItem = propertyMap[propertyName];
  if (cacheItem == null) {
    // Return default
    return defaultValue;
  }
  if (cacheItem is! bool) {
    logger.e('property "$propertyName" expected bool but got ${cacheItem.runtimeType}');
    return defaultValue;
  }
  return cacheItem;
}

int _getIntT(
    Map<String, dynamic>? propertyMap, String propertyName, int defaultValue) {
  
  var value = _getIntTN(propertyMap, propertyName);

  if (value == null) {
    // Return default
    return defaultValue;
  }
  return value;
}

int? _getIntTN(
    Map<String, dynamic>? propertyMap, String propertyName) {
  if (propertyMap == null) {
    // Return default
    return null;
  }
  var cacheItem = propertyMap[propertyName];
  if (cacheItem == null) {
    // Return default
    return null;
  }
  if (cacheItem is! int) {
    logger.e('property "$propertyName" expected int but got ${cacheItem.runtimeType}');
    return null;
  }
  return cacheItem;
}

String? _getStringTN(Map<String, dynamic>? propertyMap, String propertyName) {
  if (propertyMap == null) {
    // Return default
    return null;
  }
  var cacheItem = propertyMap[propertyName];
  if (cacheItem == null) {
    // Return default
    return null;
  }
  if (cacheItem is! String) {
    logger.e('property "$propertyName" expected String but got ${cacheItem.runtimeType}');
    return null;
  }
  return cacheItem;
}

List<String>? _getStringArrayTN(
    Map<String, dynamic>? propertyMap, String propertyName) {
  if (propertyMap == null) {
    // Return default
    return null;
  }
  var cacheItem = propertyMap[propertyName];
  if (cacheItem == null) {
    // Return default
    return null;
  }
  if (cacheItem is! List<String>) {
    logger.e('property "$propertyName" expected List<String> but got ${cacheItem.runtimeType}');
    return null;
  }
  return cacheItem;
}

T _getEnumT<T>(
    Map<String, dynamic>? propertyMap, T defaultValue, String propertyName) {

  var en = _getEnumTN(propertyMap, propertyName);

  if (en == null) {
    // Return default
    return defaultValue;
  }
  return en;
}

T? _getEnumTN<T>(
    Map<String, dynamic>? propertyMap, String propertyName) {
  if (propertyMap == null) {
    return null;
  }
  var cacheItem = propertyMap[propertyName];
  if (cacheItem == null) {
    return null;
  }
  if (cacheItem is! T) {
    logger.e('property "$propertyName" expected $T but got ${cacheItem.runtimeType}');
    return null;
  }
  return cacheItem;
}

List<Map<String, dynamic>>? _getSettingsArrayTN(
    Map<String, dynamic>? propertyMap, String propertyName) {
  if (propertyMap == null) {
    // Return default
    return null;
  }
  var cacheItem = propertyMap[propertyName];
  if (cacheItem == null) {
    // Return default
    return null;
  }
  if (cacheItem is! List<Map<String, dynamic>>) {
    logger.e('property "$propertyName" expected List<Map<String, dynamic>> but got ${cacheItem.runtimeType}');
    return null;
  }
  return cacheItem;
}

Map<String, dynamic>? _getMapTN(
    Map<String, dynamic>? propertyMap, String propertyName) {
  if (propertyMap == null) {
    // Return default
    return null;
  }
  var cacheItem = propertyMap[propertyName];
  if (cacheItem == null) {
    // Return default
    return null;
  }
  if (cacheItem is! Map<String, dynamic>) {
    logger.e('property "$propertyName" expected Map<String, dynamic> but got ${cacheItem.runtimeType}');
    return null;
  }
  return cacheItem;
}


//-------------------------------
// P R O P E R T Y   N A M E S
//-------------------------------

class PropertyName {
  static const allowEmptyValue = 'allowEmptyValue';
  static const animationPeriod = 'animationPeriod';
  static const backgroundColor = 'backgroundColor';
  static const borderAll = 'borderAll';
  static const borderBottom = 'borderBottom';
  static const borderColor = 'borderColor';
  static const borderLeft = 'borderLeft';
  static const borderRight = 'borderRight';
  static const borderTop = 'borderTop';
  static const bottom = 'bottom';
  static const checkBoxPosition = 'checkBoxPosition';
  static const color = 'color';
  static const columnSettings = 'columnSettings';
  static const dateTimeFormat = 'dateTimeFormat';
  static const displayDecimalPlaces = 'displayDecimalPlaces';
  static const displayNegativeFormat = 'displayNegativeFormat';
  static const displayThousandths = 'displayThousandths';
  static const embodiment = 'embodiment';
  static const flowDirection = 'flowDirection';
  static const focusSelection = 'focusSelection';
  static const folderIcons = 'folderIcons';
  static const fontColor = 'fontColor';
  static const fontFamily = 'fontFamily';
  static const fontSize = 'fontSize';
  static const fontStyle = 'fontStyle';
  static const fontWeight = 'fontWeight';
  static const height = 'height';
  static const hideText = 'hideText';
  static const hidingCharacter = 'hidingCharacter';
  static const horizontal = 'horizontal';
  static const horizontalAlignment = 'horizontalAlignment';
  static const horizontalItemAlignment = 'horizontalItemAlignment';
  static const horizontalTextAlignment = 'horizontalTextAlignment';
  static const imageFit = 'imageFit';
  static const insideBorderAll = 'insideBorderAll';
  static const insideBorderBottom = 'insideBorderBottom';
  static const insideBorderColor = 'insideBorderColor';
  static const insideBorderHorizontals = 'insideBorderHorizontals';
  static const insideBorderLeft = 'insideBorderLeft';
  static const insideBorderRight = 'insideBorderRight';
  static const insideBorderTop = 'insideBorderTop';
  static const insideBorderVerticals = 'insideBorderVerticals';
  static const labelItemPosition = 'labelItemPosition';
  static const layoutMethod = 'layoutMethod';
  static const left = 'left';
  static const marginAll = 'marginAll';
  static const marginBottom = 'marginBottom';
  static const marginLeft = 'marginLeft';
  static const marginRight = 'marginRight';
  static const marginTop = 'marginTop';
  static const maxDisplayLines = 'maxDisplayLines';
  static const maxValue = 'maxValue';
  static const maxLength = 'maxLength';
  static const maxLines = 'maxLines';
  static const minDisplayLines = 'minDisplayLines';
  static const minValue = 'minValue';
  static const paddingAll = 'paddingAll';
  static const paddingBottom = 'paddingBottom';
  static const paddingLeft = 'paddingLeft';
  static const paddingRight = 'paddingRight';
  static const paddingTop = 'paddingTop';
  static const propertiesForChecked = 'propertiesForChecked';
  static const propertiesForUnchecked = 'propertiesForUnchecked';
  static const popupChoices = 'popupChoices';
  static const right = 'right';
  static const rowsPerPage = 'rowsPerPage';
  static const showFirstLastButtons = 'showFirstLastButtons';
  static const size = 'size';
  static const snackbarBehavior = 'snackbarBehavior';
  static const snackbarDuration = 'snackbarDuration';
  static const snackbarShowCloseIcon = 'snackbarShowCloseIcon';
  static const sortType = 'sortType';
  static const tabHeight = 'tabHeight';
  static const top = 'top';
  static const verticalAlignment = 'verticalAlignment';
  static const verticalItemAlignment = 'verticalItemAlignment';
  static const verticalTextAlignment = 'verticalTextAlignment';
  static const width = 'width';
}


//--------------------------
// E N U M E R A T I O N S
//--------------------------

enum CheckBoxPosition { top, bottom, left, right }
Set<String> _namesofCheckBoxPosition = {
  'top',
  'bottom',
  'left',
  'right'
};

enum DisplayNegativeFormat { absolute, minusSignPrefix, parens }
Set<String> _namesofDisplayNegativeFormat = {
  'absolute',
  'minusSignPrefix',
  'parens'
};

enum FlowDirection { leftToRight, topToBottom }
Set<String> _namesofFlowDirection = {'leftToRight', 'topToBottom'};

enum FocusSelection { begin, end, all }
Set<String> _namesofFocusSelection = {
  'begin',
  'end',
  'all',
};

enum FontStyle { normal, italic }
Set<String> _namesofFontStyle = {'normal', 'italic'};

enum FontWeight { normal, bold, w1, w2, w3, w4, w5, w6, w7, w8, w9 }
Set<String> _namesofFontWeight = {
  'normal',
  'bold',
  'w1',
  'w2',
  'w3',
  'w4',
  'w5',
  'w6',
  'w7',
  'w8',
  'w9'
};

enum HorizontalAlignment { left, center, right, expand }
Set<String> _namesofHorizontalAlignment = {'left', 'center', 'right', 'expand'};

enum HorizontalItemAlignment { left, center, right, expand, baseline, spaceBetween, spaceAround, spaceEvenly }
Set<String> _namesofHorizontalItemAlignment = {
  'left',
  'center',
  'right',
  'expand',
  'baseline',
  'spaceBetween',
  'spaceAround',
  'spaceEvenly'
};

enum HorizontalTextAlignment { left, center, right, justify }
Set<String> _namesofHorizontalTextAlignment = {
  'left',
  'center',
  'right',
  'justify'
};

enum FolderIcons { chevron, fileFolder, plusMinus }
Set<String> _namesofFolderIcons = {
  'chevron',
  'fileFolder',
  'plusMinus'
};

enum ImageFit { fill, contain, cover, fitWidth, fitHeight, none, scaleDown }
Set<String> _namesofImageFit = {
  'fill',
  'contain',
  'cover',
  'fitWidth',
  'fitHeight',
  'none',
  'scaleDown'
};

enum LabelItemPosition { top, bottom, left, right }
Set<String> _namesofLabelItemPosition = {
  'top',
  'bottom',
  'left',
  'right'
};

enum LayoutMethod { flow, positioned }
Set<String> _namesofLayoutMethod = {'flow', 'positioned'};

enum SnackbarBehavior { fixed, floating }
Set<String> _namesofSnackbarBehavior = {'fixed', 'floating'};

enum SortType { none, text, numeric, tag, dateTime }
Set<String> _namesofSortType = {
  'none',
  'text',
  'numeric',
  'tag',
  'dateTime'
};

enum VerticalAlignment { top, middle, bottom, expand }
Set<String> _namesofVerticalAlignment = {'top', 'middle', 'bottom', 'expand'};

enum VerticalItemAlignment { top, middle, bottom, expand, baseline, spaceBetween, spaceAround, spaceEvenly }
Set<String> _namesofVerticalItemAlignment = {
  'top',
  'middle',
  'bottom',
  'expand',
  'baseline',
  'spaceBetween',
  'spaceAround',
  'spaceEvenly'
};

enum VerticalTextAlignment { top, middle, bottom }
Set<String> _namesofVerticalTextAlignment = {'top', 'middle', 'bottom'};


// -----------------------------------------------------
// P R O P E R T Y   M A P P I N G   F U N C T I O N S
// -----------------------------------------------------


bool _mapCheckDefaultProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.checkBoxPosition:
      propertyMap[name] = getEnumProp<CheckBoxPosition>(value, CheckBoxPosition.values, _namesofCheckBoxPosition, name);
    case PropertyName.labelItemPosition:
      propertyMap[name] = getEnumProp<LabelItemPosition>(value, LabelItemPosition.values, _namesofLabelItemPosition, name);
    default:
      return false;
  }
  return true;
}

bool _mapCheckToggleButtonProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.labelItemPosition:
      propertyMap[name] = getEnumProp<LabelItemPosition>(value, LabelItemPosition.values, _namesofLabelItemPosition, name);
    case PropertyName.propertiesForChecked:
      propertyMap[name] = getMapProp(value);
    case PropertyName.propertiesForUnchecked:
      propertyMap[name] = getMapProp(value);
    default:
      return false;
  }
  return true;
}

bool _mapColumnSettingsProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.width:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.sortType:
      propertyMap[name] = getEnumProp<SortType>(value, SortType.values, _namesofSortType, name);
    case PropertyName.dateTimeFormat:
      propertyMap[name] = getStringProp(value);
    default:
      return false;
  }
  return true;
}

bool _mapCommandDefaultProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.labelItemPosition:
      propertyMap[name] = getEnumProp<LabelItemPosition>(value, LabelItemPosition.values, _namesofLabelItemPosition, name);
    default:
      return false;
  }
  return true;
}

bool _mapCommandOutlinedButtonProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.labelItemPosition:
      propertyMap[name] = getEnumProp<LabelItemPosition>(value, LabelItemPosition.values, _namesofLabelItemPosition, name);
    default:
      return false;
  }
  return true;
}

bool _mapCommonProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.backgroundColor:
      propertyMap[name] = getColorProp(value, name);
    case PropertyName.borderAll:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.borderBottom:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.borderColor:
      propertyMap[name] = getColorProp(value, name);
    case PropertyName.borderLeft:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.borderRight:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.borderTop:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.bottom:
      propertyMap[name] = getNumericProp(value, name);
    case PropertyName.embodiment:
      propertyMap[name] = getStringProp(value);
    case PropertyName.height:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.horizontalAlignment:
      propertyMap[name] = getEnumProp<HorizontalAlignment>(
          value, HorizontalAlignment.values, _namesofHorizontalAlignment, name);
    case PropertyName.left:
      propertyMap[name] = getNumericProp(value, name);
    case PropertyName.marginAll:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.marginBottom:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.marginLeft:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.marginRight:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.marginTop:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.paddingAll:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.paddingBottom:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.paddingLeft:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.paddingRight:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.paddingTop:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.right:
      propertyMap[name] = getNumericProp(value, name);
    case PropertyName.top:
      propertyMap[name] = getNumericProp(value, name);
    case PropertyName.verticalAlignment:
      propertyMap[name] = getEnumProp<VerticalAlignment>(
          value, VerticalAlignment.values, _namesofVerticalAlignment, name);
    case PropertyName.width:
      propertyMap[name] = getNumericProp(value, name, 0);
    default:
      return false;
  }
  return true;
}

bool _mapFrameDefaultProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.flowDirection:
      propertyMap[name] = getEnumProp<FlowDirection>(
          value, FlowDirection.values, _namesofFlowDirection, name);
    case PropertyName.horizontalItemAlignment:
      propertyMap[name] = getEnumProp<HorizontalItemAlignment>(
          value, HorizontalItemAlignment.values, _namesofHorizontalItemAlignment, name);
    case PropertyName.layoutMethod:
      propertyMap[name] = getEnumProp<LayoutMethod>(
          value, LayoutMethod.values, _namesofLayoutMethod, name);
    case PropertyName.verticalItemAlignment:
      propertyMap[name] = getEnumProp<VerticalItemAlignment>(
          value, VerticalItemAlignment.values, _namesofVerticalItemAlignment, name);
    default:
      return false;
  }
  return true;
}

bool _mapFrameSnackbarProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.snackbarBehavior:
      propertyMap[name] = getEnumProp<SnackbarBehavior>(
          value, SnackbarBehavior.values, _namesofSnackbarBehavior, name);
    case PropertyName.snackbarDuration:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.snackbarShowCloseIcon:
      propertyMap[name] = getBoolProp(value, name);
    default:
      return false;
  }
  return true;
}

bool _mapGroupDefaultProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.horizontalItemAlignment:
      propertyMap[name] = getEnumProp<HorizontalItemAlignment>(
          value, HorizontalItemAlignment.values, _namesofHorizontalItemAlignment, name);
    case PropertyName.verticalItemAlignment:
      propertyMap[name] = getEnumProp<VerticalItemAlignment>(
          value, VerticalItemAlignment.values, _namesofVerticalItemAlignment, name);
    default:
      return false;
  }
  return true;
}

bool _mapIconDefaultProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.color:
      propertyMap[name] = getColorProp(value, name);
    case PropertyName.size:
      propertyMap[name] = getNumericProp(value, name, 0);
    default:
      return false;
  }
  return true;
}

bool _mapImageDefaultProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.imageFit:
      propertyMap[name] = getEnumProp<ImageFit>(
          value, ImageFit.values, _namesofImageFit, name);
    default:
      return false;
  }
  return true;
}

bool _mapFolderDefaultProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.folderIcons:
      propertyMap[name] = getEnumProp<FolderIcons>(
          value, FolderIcons.values, _namesofFolderIcons, name);
    default:
      return false;
  }
  return true;
}

bool _mapListDefaultProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.horizontal:
      propertyMap[name] = getBoolProp(value, name);
    default:
      return false;
  }
  return true;
}

bool _mapListTabbedProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.animationPeriod:
      propertyMap[name] = getIntProp(value, name, 0, 5000);
    case PropertyName.tabHeight:
      propertyMap[name] = getNumericProp(value, name, 0);
    default:
      return false;
  }
  return true;
}

bool _mapNumericFieldColorProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.allowEmptyValue:
      propertyMap[name] = getBoolProp(value, name);
    case PropertyName.focusSelection:
      propertyMap[name] = getEnumProp<FocusSelection>(value, FocusSelection.values, _namesofFocusSelection, name);
    default:
      return false;
  }
  return true;
}

bool _mapNumericFieldDefaultProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.allowEmptyValue:
      propertyMap[name] = getBoolProp(value, name);
    case PropertyName.displayDecimalPlaces:
      propertyMap[name] = getIntProp(value, name, -15, 15);
    case PropertyName.displayNegativeFormat:
      propertyMap[name] = getEnumProp<DisplayNegativeFormat>(
          value, DisplayNegativeFormat.values, _namesofDisplayNegativeFormat, name);
    case PropertyName.displayThousandths:
      propertyMap[name] = getBoolProp(value, name);
    case PropertyName.minValue:
      propertyMap[name] = getNumericProp(value, name);
    case PropertyName.maxValue:
      propertyMap[name] = getNumericProp(value, name);
    case PropertyName.popupChoices:
      propertyMap[name] = getStringArrayProp(value);
    case PropertyName.focusSelection:
      propertyMap[name] = getEnumProp<FocusSelection>(value, FocusSelection.values, _namesofFocusSelection, name);
    default:
      return false;
  }
  return true;
}

bool _mapNumericFieldFontSizeProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.focusSelection:
      propertyMap[name] = getEnumProp<FocusSelection>(value, FocusSelection.values, _namesofFocusSelection, name);
    default:
      return false;
  }
  return true;
}

bool _mapTableDefaultProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.columnSettings:
      propertyMap[name] = getMapArrayProp(value);
    case PropertyName.insideBorderAll:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.insideBorderBottom:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.insideBorderColor:
      propertyMap[name] = getColorProp(value, name);
    case PropertyName.insideBorderHorizontals:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.insideBorderLeft:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.insideBorderRight:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.insideBorderTop:
      propertyMap[name] = getNumericProp(value, name, 0);
    case PropertyName.insideBorderVerticals:
      propertyMap[name] = getNumericProp(value, name, 0);
    default:
      return false;
  }
  return true;
}

bool _mapTablePagedProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.columnSettings:
      propertyMap[name] = getMapArrayProp(value);
    case PropertyName.rowsPerPage:
      propertyMap[name] = getIntProp(value, name, 0, 1000);
    case PropertyName.showFirstLastButtons:
      propertyMap[name] = getBoolProp(value, name);
    default:
      return false;
  }
  return true;
}

bool _mapTextDefaultProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.fontColor:
      propertyMap[name] = getColorProp(value, name);
    case PropertyName.fontFamily:
      propertyMap[name] = getStringProp(value);
    case PropertyName.fontSize:
      propertyMap[name] = getNumericProp(value, name);
    case PropertyName.fontStyle:
      propertyMap[name] =
          getEnumProp<FontStyle>(value, FontStyle.values, _namesofFontStyle, name);
    case PropertyName.fontWeight:
      propertyMap[name] =
          getEnumProp<FontWeight>(value, FontWeight.values, _namesofFontWeight, name);
    case PropertyName.horizontalTextAlignment:
      propertyMap[name] = getEnumProp<HorizontalTextAlignment>(value,
          HorizontalTextAlignment.values, _namesofHorizontalTextAlignment, name);
    case PropertyName.verticalTextAlignment:
      propertyMap[name] = getEnumProp<VerticalTextAlignment>(
          value, VerticalTextAlignment.values, _namesofVerticalTextAlignment, name);
    default:
      return false;
  }
  return true;
}

bool _mapTextFieldDefaultProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.hideText:
      propertyMap[name] = getBoolProp(value, name);
    case PropertyName.hidingCharacter:
      propertyMap[name] = getStringProp(value);
    case PropertyName.maxDisplayLines:
      propertyMap[name] = getIntProp(value, name, 1, 1000);
    case PropertyName.maxLength:
      propertyMap[name] = getIntProp(value, name, 0, 1000000);
    case PropertyName.maxLines:
      propertyMap[name] = getIntProp(value, name, 0, 1000000);
    case PropertyName.minDisplayLines:
      propertyMap[name] = getIntProp(value, name, 1, 1000);
    case PropertyName.focusSelection:
      propertyMap[name] = getEnumProp<FocusSelection>(value, FocusSelection.values, _namesofFocusSelection, name);
    default:
      return false;
  }
  return true;
}

bool _mapTreeDefaultProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    default:
      return false;
  }
}

bool _mapTristateDefaultProperty(
    Map<String, dynamic> propertyMap, String name, dynamic value) {
  switch (name) {
    case PropertyName.checkBoxPosition:
      propertyMap[name] = getEnumProp<CheckBoxPosition>(value, CheckBoxPosition.values, _namesofCheckBoxPosition, name);
    case PropertyName.labelItemPosition:
      propertyMap[name] = getEnumProp<LabelItemPosition>(value, LabelItemPosition.values, _namesofLabelItemPosition, name);
    default:
      return false;
  }
  return true;
}

// -------------------------------------------
// P R O P E R T I E S   B A S E   C L A S S 
// -------------------------------------------

class Properties {
  Properties({Properties? initialProperties}) : areCommonProps = false {
    if (initialProperties != null) {
      var initialPropertyMap = initialProperties.propertyMap;
      if (initialPropertyMap != null) {
        propertyMap = Map<String, dynamic>.of(initialPropertyMap);
        areCommonProps = initialProperties.areCommonProps;
      }
    }
  }

  bool areCommonProps;
  Map<String, dynamic>? propertyMap;
}

// ------------------------------------------------
// P R O P E R T Y   A C C E S S   C L A S S E S
// ------------------------------------------------

mixin CheckDefaultPropertyAccess on Properties {
  CheckBoxPosition get checkBoxPosition => _getEnumT<CheckBoxPosition>(propertyMap, CheckBoxPosition.left,  PropertyName.checkBoxPosition);
  LabelItemPosition get labelItemPosition => _getEnumT<LabelItemPosition>(propertyMap, LabelItemPosition.left, PropertyName.labelItemPosition);
}

mixin CheckToggleButtonPropertyAccess on Properties {

  CommonPropertyAccess? _cachedPropertiesForChecked;
  CommonPropertyAccess? _cachedPropertiesForUnchecked;

  CommonPropertyAccess? get propertiesForChecked {
    if (_cachedPropertiesForChecked == null) {
      var m = _getMapTN(propertyMap, PropertyName.propertiesForChecked);

      if (m != null) {
        _cachedPropertiesForChecked = CommonProperties.fromMap(m);
      }
    }
    return _cachedPropertiesForChecked;
  }

  CommonPropertyAccess? get propertiesForUnchecked {
    if (_cachedPropertiesForUnchecked == null) {
      var m = _getMapTN(propertyMap, PropertyName.propertiesForUnchecked);

      if (m != null) {
        _cachedPropertiesForUnchecked = CommonProperties.fromMap(m);
      }
    }
    return _cachedPropertiesForUnchecked;
  }

  LabelItemPosition get labelItemPosition => _getEnumT<LabelItemPosition>(propertyMap, LabelItemPosition.left, PropertyName.labelItemPosition);
}

mixin ColumnSettingsPropertyAccess on Properties {
  double? get width => _getDoubleTN(propertyMap, PropertyName.width);
  SortType? get sortType => _getEnumTN<SortType>(propertyMap, PropertyName.sortType);
  String? get dateTimeFormat => _getStringTN(propertyMap, PropertyName.dateTimeFormat);
}

mixin CommandDefaultPropertyAccess on Properties {
  LabelItemPosition get labelItemPosition => _getEnumT<LabelItemPosition>(propertyMap, LabelItemPosition.left, PropertyName.labelItemPosition);
}

mixin CommandOutlinedButtonPropertyAccess on Properties {
  LabelItemPosition get labelItemPosition => _getEnumT<LabelItemPosition>(propertyMap, LabelItemPosition.left, PropertyName.labelItemPosition);
}

mixin CommonPropertyAccess on Properties {
  bool? _isPadding;
  bool? _isBorder;
  bool? _isMargin;
  bool? _isSizing;
  bool? _isPositioning;

  bool get isPadding {
    _isPadding ??= (paddingAll != null ||
        paddingLeft != null ||
        paddingRight != null ||
        paddingTop != null ||
        paddingBottom != null);

    return _isPadding!;
  }

  bool get isBorder {
    _isBorder ??= (borderAll != null ||
        borderLeft != null ||
        borderRight != null ||
        borderTop != null ||
        borderBottom != null);

    return _isBorder!;
  }

  bool get isMargin {
    _isMargin = _isMargin ??= (marginAll != null ||
        marginLeft != null ||
        marginRight != null ||
        marginTop != null ||
        marginBottom != null);
    return _isMargin!;
  }

  bool get isSizing {
    _isSizing ??= (width != null || height != null);
    return _isSizing!;
  }

  bool get isPositioning {
    _isPositioning ??=
        (left != null || right != null || top != null || bottom != null);
    return _isPositioning!;
  }

  Color? get backgroundColor =>
      _getColorTN(propertyMap, PropertyName.backgroundColor);
  double? get borderAll => _getDoubleTN(propertyMap, PropertyName.borderAll);
  double? get borderBottom =>
      _getDoubleTN(propertyMap, PropertyName.borderBottom);
  Color? get borderColor => _getColorTN(propertyMap, PropertyName.borderColor);
  double? get borderLeft => _getDoubleTN(propertyMap, PropertyName.borderLeft);
  double? get borderRight => _getDoubleTN(propertyMap, PropertyName.borderRight);
  double? get borderTop => _getDoubleTN(propertyMap, PropertyName.borderTop);
  double? get bottom => _getDoubleTN(propertyMap, PropertyName.bottom);
  String? get embodiment => _getStringTN(propertyMap, PropertyName.embodiment);
  double? get height => _getDoubleTN(propertyMap, PropertyName.height);
  HorizontalAlignment? get horizontalAlignment => _getEnumTN<HorizontalAlignment>(
      propertyMap, PropertyName.horizontalAlignment);
  double? get left => _getDoubleTN(propertyMap, PropertyName.left);
  double? get marginAll => _getDoubleTN(propertyMap, PropertyName.marginAll);
  double? get marginBottom =>
      _getDoubleTN(propertyMap, PropertyName.marginBottom);
  double? get marginLeft => _getDoubleTN(propertyMap, PropertyName.marginLeft);
  double? get marginRight => _getDoubleTN(propertyMap, PropertyName.marginRight);
  double? get marginTop => _getDoubleTN(propertyMap, PropertyName.marginTop);
  double? get paddingAll => _getDoubleTN(propertyMap, PropertyName.paddingAll);
  double? get paddingBottom =>
      _getDoubleTN(propertyMap, PropertyName.paddingBottom);
  double? get paddingLeft => _getDoubleTN(propertyMap, PropertyName.paddingLeft);
  double? get paddingRight =>
      _getDoubleTN(propertyMap, PropertyName.paddingRight);
  double? get paddingTop => _getDoubleTN(propertyMap, PropertyName.paddingTop);
  double? get right => _getDoubleTN(propertyMap, PropertyName.right);
  double? get top => _getDoubleTN(propertyMap, PropertyName.top);
  VerticalAlignment? get verticalAlignment => _getEnumTN<VerticalAlignment>(
      propertyMap, PropertyName.verticalAlignment);
  double? get width => _getDoubleTN(propertyMap, PropertyName.width);
}

mixin FrameDefaultPropertyAccess on Properties {
  FlowDirection get flowDirection => _getEnumT<FlowDirection>(
      propertyMap, FlowDirection.topToBottom, PropertyName.flowDirection);
  HorizontalItemAlignment get horizontalItemAlignment => _getEnumT<HorizontalItemAlignment>(
      propertyMap, HorizontalItemAlignment.left, PropertyName.horizontalItemAlignment);
  LayoutMethod get layoutMethod => _getEnumT<LayoutMethod>(
      propertyMap, LayoutMethod.flow, PropertyName.layoutMethod);
  VerticalItemAlignment get verticalItemAlignment => _getEnumT<VerticalItemAlignment>(
      propertyMap, VerticalItemAlignment.top, PropertyName.verticalItemAlignment);
}

mixin FrameSnackbarPropertyAccess on Properties {
  SnackbarBehavior get snackbarBehavior => _getEnumT<SnackbarBehavior>(
      propertyMap, SnackbarBehavior.fixed, PropertyName.snackbarBehavior);
  double? get snackbarDuration =>
      _getDoubleTN(propertyMap, PropertyName.snackbarDuration);
  bool get snackbarShowCloseIcon =>
      _getYesNoT(propertyMap, PropertyName.snackbarShowCloseIcon, false);
}

mixin GroupDefaultPropertyAccess on Properties {
  HorizontalItemAlignment get horizontalItemAlignment => _getEnumT<HorizontalItemAlignment>(
      propertyMap, HorizontalItemAlignment.left, PropertyName.horizontalItemAlignment);
  VerticalItemAlignment get verticalItemAlignment => _getEnumT<VerticalItemAlignment>(
      propertyMap, VerticalItemAlignment.top, PropertyName.verticalItemAlignment);
}

mixin IconDefaultPropertyAccess on Properties {
  Color? get color => _getColorTN(propertyMap, PropertyName.color);
  double? get size => _getDoubleTN(propertyMap, PropertyName.size);
}

mixin FolderDefaultPropertyAccess on Properties {
  FolderIcons get folderIcons => _getEnumT<FolderIcons>(
      propertyMap, FolderIcons.chevron, PropertyName.folderIcons);
}

mixin ImageDefaultPropertyAccess on Properties {
  ImageFit get imageFit => _getEnumT<ImageFit>(propertyMap, ImageFit.contain, 'imageFit');
}

mixin ListCardPropertyAccess on Properties {
  bool get horizontal =>
      _getYesNoT(propertyMap, PropertyName.horizontal, false);
}

mixin ListDefaultPropertyAccess on Properties {
  bool get horizontal =>
      _getYesNoT(propertyMap, PropertyName.horizontal, false);
}

mixin ListPropertyPropertyAccess on Properties {
  bool get horizontal =>
      _getYesNoT(propertyMap, PropertyName.horizontal, false);
}

mixin ListTabbedPropertyAccess on Properties {
  int get animationPeriod =>
      _getIntT(propertyMap, PropertyName.animationPeriod, 0);
  double? get tabHeight => _getDoubleTN(propertyMap, PropertyName.tabHeight);
}

class NothingProperties extends Properties {
  NothingProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    return;
  }
}

mixin NumericFieldColorPropertyAccess on Properties {
  bool get allowEmptyValue =>
      _getYesNoT(propertyMap, PropertyName.allowEmptyValue, false);
  FocusSelection get focusSelection => _getEnumT(propertyMap,
      FocusSelection.all, PropertyName.focusSelection);
}

mixin NumericFieldDefaultPropertyAccess on Properties {
  bool get allowEmptyValue =>
      _getYesNoT(propertyMap, PropertyName.allowEmptyValue, false);
  int get displayDecimalPlaces =>
      _getIntT(propertyMap, PropertyName.displayDecimalPlaces, -15);
  DisplayNegativeFormat get displayNegativeFormat => _getEnumT(
      propertyMap,
      DisplayNegativeFormat.minusSignPrefix,
      PropertyName.displayNegativeFormat);
  bool get displayThousandths =>
      _getYesNoT(propertyMap, PropertyName.displayThousandths, false);
  double? get maxValue => _getDoubleTN(propertyMap, PropertyName.maxValue);
  double? get minValue => _getDoubleTN(propertyMap, PropertyName.minValue);
  List<String>? get popupChoices =>
      _getStringArrayTN(propertyMap, PropertyName.popupChoices);
  FocusSelection get focusSelection => _getEnumT(propertyMap,
      FocusSelection.all, PropertyName.focusSelection);
}

mixin NumericFieldFontSizePropertyAccess on Properties {
  FocusSelection get focusSelection => _getEnumT(propertyMap,
      FocusSelection.all, PropertyName.focusSelection);
}

mixin TableDefaultPropertyAccess on Properties {

  double? get insideBorderAll => _getDoubleTN(propertyMap, PropertyName.insideBorderAll);
  double? get insideBorderBottom =>
      _getDoubleTN(propertyMap, PropertyName.insideBorderBottom);
  Color? get insideBorderColor => _getColorTN(propertyMap, PropertyName.insideBorderColor);
  double? get insideBorderHorizontals => _getDoubleTN(propertyMap, PropertyName.insideBorderHorizontals);
  double? get insideBorderLeft => _getDoubleTN(propertyMap, PropertyName.insideBorderLeft);
  double? get insideBorderRight => _getDoubleTN(propertyMap, PropertyName.insideBorderRight);
  double? get insideBorderTop => _getDoubleTN(propertyMap, PropertyName.insideBorderTop);
  double? get insideBorderVerticals => _getDoubleTN(propertyMap, PropertyName.insideBorderVerticals);

  List<ColumnSettingsPropertyAccess>? _cachedColumnSettings;

  List<ColumnSettingsPropertyAccess> get columnSettings {
    if (_cachedColumnSettings == null) {
      var sa = _getSettingsArrayTN(propertyMap, PropertyName.columnSettings);

      if (sa != null) {
        _cachedColumnSettings = List<ColumnSettingsProperties>.generate(sa.length, (int index) => ColumnSettingsProperties.fromMap(sa[index]), growable: false);
      } else {
        _cachedColumnSettings = List<ColumnSettingsPropertyAccess>.empty();
      }
    }

    return _cachedColumnSettings!;
  }

  bool? _isInsideBorder;

  bool get isInsideBorder {
    _isInsideBorder ??= (insideBorderAll != null ||
        insideBorderBottom != null ||
        insideBorderHorizontals != null ||
        insideBorderLeft != null ||
        insideBorderRight != null ||
        insideBorderTop != null ||
        insideBorderVerticals != null
        );

    return _isInsideBorder!;
  }

}

mixin TablePagedPropertyAccess on Properties {
  List<ColumnSettingsPropertyAccess>? _cachedColumnSettings;

  List<ColumnSettingsPropertyAccess> get columnSettings {
    if (_cachedColumnSettings == null) {
      var sa = _getSettingsArrayTN(propertyMap, PropertyName.columnSettings);

      if (sa != null) {
        _cachedColumnSettings = List<ColumnSettingsProperties>.generate(sa.length, (int index) => ColumnSettingsProperties.fromMap(sa[index]), growable: false);
      } else {
        _cachedColumnSettings = List<ColumnSettingsPropertyAccess>.empty();
      }
    }

    return _cachedColumnSettings!;
  }

  int get rowsPerPage => _getIntT(propertyMap, PropertyName.rowsPerPage, 5);
  bool get showFirstLastButtons => _getYesNoT(propertyMap, PropertyName.showFirstLastButtons, false);
}

mixin TextDefaultPropertyAccess on Properties {
  Color? get fontColor => _getColorTN(propertyMap, PropertyName.fontColor);
  String? get fontFamily => _getStringTN(propertyMap, PropertyName.fontFamily);
  double? get fontSize => _getDoubleTN(propertyMap, PropertyName.fontSize);
  FontStyle? get fontStyle => _getEnumTN<FontStyle>(
      propertyMap, PropertyName.fontStyle);
  FontWeight? get fontWeight => _getEnumTN<FontWeight>(
      propertyMap, PropertyName.fontWeight);
  HorizontalTextAlignment get horizontalTextAlignment => _getEnumT(propertyMap,
      HorizontalTextAlignment.center, PropertyName.horizontalTextAlignment);
  VerticalTextAlignment get verticalTextAlignment => _getEnumT(propertyMap,
      VerticalTextAlignment.middle, PropertyName.verticalTextAlignment);
}

mixin TextFieldDefaultPropertyAccess on Properties {
  int? get maxDisplayLines =>
      _getIntTN(propertyMap, PropertyName.maxDisplayLines);
  int? get maxLength =>
      _getIntTN(propertyMap, PropertyName.maxLength);
  int? get maxLines =>
      _getIntTN(propertyMap, PropertyName.maxLines);
  int? get minDisplayLines =>
      _getIntTN(propertyMap, PropertyName.minDisplayLines);
  bool get hideText =>
      _getYesNoT(propertyMap, PropertyName.hideText, false);
  String? get hidingCharacter =>
      _getStringTN(propertyMap, PropertyName.hidingCharacter);
  FocusSelection get focusSelection => _getEnumT(propertyMap,
      FocusSelection.end, PropertyName.focusSelection);
}

mixin TreeDefaultPropertyAccess on Properties {}

mixin TristateDefaultPropertyAccess on Properties {
  CheckBoxPosition get checkBoxPosition => _getEnumT<CheckBoxPosition>(propertyMap, CheckBoxPosition.left,  PropertyName.checkBoxPosition);
  LabelItemPosition get labelItemPosition => _getEnumT<LabelItemPosition>(propertyMap, LabelItemPosition.left, PropertyName.labelItemPosition);
}

// ------------------------------------------------
// P R O P E R T I E S   C L A S S E S
// ------------------------------------------------

class FolderDefaultProperties extends Properties
    with CommonPropertyAccess, FolderDefaultPropertyAccess {
  FolderDefaultProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapFolderDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for FolderDefaultProperties');
      }
    }
  }
}

class CommonProperties extends Properties with CommonPropertyAccess {
  CommonProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for CommonProperties');
      }
    }
  }
}

class CheckDefaultProperties extends Properties
    with CommonPropertyAccess, CheckDefaultPropertyAccess, TextDefaultPropertyAccess {
  CheckDefaultProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapCheckDefaultProperty(propertyMap!, kv.key, kv.value);
      matched |= _mapTextDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for CheckDefaultProperties');
      }
    }
  }
}

class CheckToggleButtonProperties extends Properties
    with CommonPropertyAccess, CheckToggleButtonPropertyAccess, TextDefaultPropertyAccess {
  CheckToggleButtonProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapCheckToggleButtonProperty(propertyMap!, kv.key, kv.value);
      matched |= _mapTextDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for CheckToggleButtonProperties');
      }
    }
  }
}

class ChoiceDefaultProperties extends Properties
    with CommonPropertyAccess, TextDefaultPropertyAccess {
  ChoiceDefaultProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapTextDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for ChoiceDefaultProperties');
      }
    }
  }
}

class ColumnSettingsProperties extends Properties
    with ColumnSettingsPropertyAccess {
  ColumnSettingsProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapColumnSettingsProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for ColumnSettingsProperties');
      }
    }
  }
}

class CommandDefaultProperties extends Properties
    with CommonPropertyAccess, CommandDefaultPropertyAccess, TextDefaultPropertyAccess {
  CommandDefaultProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapCommandDefaultProperty(propertyMap!, kv.key, kv.value);
      matched |= _mapTextDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for CommandDefaultProperties');
      }
    }
  }
}

class CommandOutlinedButtonProperties extends Properties
    with CommonPropertyAccess, CommandDefaultPropertyAccess, TextDefaultPropertyAccess {
  CommandOutlinedButtonProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapCommandOutlinedButtonProperty(propertyMap!, kv.key, kv.value);
      matched |= _mapTextDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for CommandOutlinedButtonProperties');
      }
    }
  }
}

class ExportFileDefaultProperties extends Properties
    with CommonPropertyAccess, TextDefaultPropertyAccess {
  ExportFileDefaultProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapTextDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for ExportFileDefaultProperties');
      }
    }
  }
}

class FrameDefaultProperties extends Properties
    with CommonPropertyAccess, FrameDefaultPropertyAccess {
  FrameDefaultProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapFrameDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for FrameDefaultProperties');
      }
    }
  }
}

class FrameSnackbarProperties extends Properties
    with CommonPropertyAccess, FrameSnackbarPropertyAccess {
  FrameSnackbarProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapFrameSnackbarProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for FrameSnackbarProperties');
      }
    }
  }
}

class GroupDefaultProperties extends Properties
    with CommonPropertyAccess, GroupDefaultPropertyAccess {
  GroupDefaultProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapGroupDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for GroupDefaultProperties');
      }
    }
  }
}

class IconDefaultProperties extends Properties
    with CommonPropertyAccess, IconDefaultPropertyAccess {
  IconDefaultProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapIconDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for IconDefaultProperties');
      }
    }
  }
}

class ImageDefaultProperties extends Properties
    with CommonPropertyAccess, ImageDefaultPropertyAccess {
  ImageDefaultProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapImageDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for ImageDefaultProperties');
      }
    }
  }
}

class ImortFileDefaultProperties extends Properties
    with CommonPropertyAccess, TextDefaultPropertyAccess {
  ImortFileDefaultProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapTextDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for ImortFileDefaultProperties');
      }
    }
  }
}

class ListDefaultProperties extends Properties
    with CommonPropertyAccess, ListDefaultPropertyAccess {
  ListDefaultProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapListDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for ListDefaultProperties');
      }
    }
  }
}

// ALSO GENERATES DUPLICATES ListCardProperties, ListPropertyProperties
class ListTabbedProperties extends Properties
    with CommonPropertyAccess, ListTabbedPropertyAccess {
  ListTabbedProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapListTabbedProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for ListTabbedProperties');
      }
    }
  }
}

class NumericFieldColorProperties extends Properties
    with CommonPropertyAccess, NumericFieldDefaultPropertyAccess, TextDefaultPropertyAccess {
  NumericFieldColorProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapNumericFieldColorProperty(propertyMap!, kv.key, kv.value);
      matched |= _mapTextDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for NumericFieldColorProperties');
      }
    }
  }
}

class NumericFieldDefaultProperties extends Properties
    with CommonPropertyAccess, NumericFieldDefaultPropertyAccess, TextDefaultPropertyAccess {
  NumericFieldDefaultProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapNumericFieldDefaultProperty(propertyMap!, kv.key, kv.value);
      matched |= _mapTextDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for NumericFieldDefaultProperties');
      }
    }
  }
}

class NumericFieldFontSizeProperties extends Properties
    with CommonPropertyAccess, NumericFieldFontSizePropertyAccess, TextDefaultPropertyAccess {
  NumericFieldFontSizeProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapNumericFieldFontSizeProperty(propertyMap!, kv.key, kv.value);
      matched |= _mapTextDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for NumericFieldFontSizeProperties');
      }
    }
  }
}

class TableDefaultProperties extends Properties
    with CommonPropertyAccess, TableDefaultPropertyAccess {
  TableDefaultProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapTableDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for TableDefaultProperties');
      }
    }
  }
}

class TablePagedProperties extends Properties
    with CommonPropertyAccess, TablePagedPropertyAccess {
  TablePagedProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapTablePagedProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for TablePagedProperties');
      }
    }
  }
}

class TextDefaultProperties extends Properties
    with CommonPropertyAccess, TextDefaultPropertyAccess {
  TextDefaultProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapTextDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for TextDefaultProperties');
      }
    }
  }
}

class TextFieldDefaultProperties extends Properties
    with CommonPropertyAccess, TextFieldDefaultPropertyAccess, TextDefaultPropertyAccess {
  TextFieldDefaultProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapTextFieldDefaultProperty(propertyMap!, kv.key, kv.value);
      matched |= _mapTextDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for TextFieldDefaultProperties');
      }
    }
  }
}

class TreeDefaultProperties extends Properties
    with CommonPropertyAccess, TreeDefaultPropertyAccess {
  TreeDefaultProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapTreeDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for TreeDefaultProperties');
      }
    }
  }
}

class TristateDefaultProperties extends Properties
    with CommonPropertyAccess, TristateDefaultPropertyAccess, TextDefaultPropertyAccess {
  TristateDefaultProperties.fromMap(Map<String, dynamic>? embodimentMap,
      {super.initialProperties}) {
    if (embodimentMap == null || embodimentMap.isEmpty) {
      return;
    }
    propertyMap ??= {};
    for (var kv in embodimentMap.entries) {
      var matched = _mapCommonProperty(propertyMap!, kv.key, kv.value);
      areCommonProps |= matched;
      matched |= _mapTristateDefaultProperty(propertyMap!, kv.key, kv.value);
      matched |= _mapTextDefaultProperty(propertyMap!, kv.key, kv.value);
      if (!matched && kv.key != PropertyName.embodiment) {
        logger.e('unknown property "${kv.key}" for TristateDefaultProperties');
      }
    }
  }
}

class EmbodimentProperty {
  static String getFromMap(Map<String, dynamic>? embodimentMap) {
    if (embodimentMap == null) {
      // Return default
      return '';
    }
    var item = embodimentMap[PropertyName.embodiment];
    if (item == null || item is! String) {
      // Return default
      return '';
    }

    return item;
  }
}
