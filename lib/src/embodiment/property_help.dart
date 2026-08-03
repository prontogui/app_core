// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:dartlib/log.dart';
import 'package:flutter/material.dart';

String getEnumStringProp(
    dynamic value, String defaultValue, Set<String> validEnums, String name) {
  if (value is! String) {
    logger.e('property "$name": value is not a string');
    return defaultValue;
  }

  if (!validEnums.contains(value)) {
    logger.e('property "$name": invalid enum value "$value"');
    return defaultValue;
  }
  return value;
}

T? getEnumProp<T extends Enum>(
    dynamic value, List<T> enumValues, Set<String> enumNames, String name) {
  var enumString = getEnumStringProp(value, '', enumNames, name);
  if (enumString.isEmpty) {
    return null;
  }
  return enumValues.byName(enumString);
}

String? getStringProp(dynamic value) {
  if (value is! String) {
    return null;
  }
  return value;
}

List<String>? getStringArrayProp(dynamic value) {
  if (value is! List) {
    return null;
  }

  try {
    return List<String>.from(value);
  } catch (e) {
    return null;
  }
}

List<Map<String, dynamic>>? getMapArrayProp(dynamic value) {
  if (value is! List || value.isEmpty || value[0] is! Map) {
    return null;
  }

  try {
    return List<Map<String, dynamic>>.from(value);
  } catch (e) {
    return null;
  }
}

Map<String, dynamic>? getMapProp(dynamic value) {
  if (value is! Map || value.isEmpty) {
    return null;
  }

  try {
    return Map<String, dynamic>.from(value);
  } catch (e) {
    return null;
  }
}

Color? getColorProp(dynamic value, String name) {
  if (value is! String) {
    logger.e('property "$name": value is not a string');
    return null;
  }

  var colorSpec = value.toLowerCase();

  // Named color with optional swatch index?

  // Color specified as ARGB (e.g. "#FFFFFFFF")?
  if (colorSpec.startsWith("#") && colorSpec.length == 9) {
    var a = int.tryParse(colorSpec.substring(1, 3), radix: 16);
    var r = int.tryParse(colorSpec.substring(3, 5), radix: 16);
    var g = int.tryParse(colorSpec.substring(5, 7), radix: 16);
    var b = int.tryParse(colorSpec.substring(7), radix: 16);
    if (a == null || r == null || g == null || b == null) {
      return null;
    }

    return Color.fromARGB(a, r, g, b);
  }

  logger.e('property "$name": invalid color value "$value"');
  return null;
}

double? getNumericProp(dynamic value, String name,
    [double minValue = double.negativeInfinity,
    double maxValue = double.infinity]) {

  late double n;

  if (value is int) {
    n = value.toDouble();
  } else if (value is double) {
    n = value;
  } else if (value is String) {
    var parsedValue = double.tryParse(value);
    if (parsedValue == null) {
      logger.e('property "$name": cannot parse "$value" as a number');
      return null;
    }
    n = parsedValue;
  } else {
    logger.e('property "$name": value is not a number');
    return null;
  }
  if (n < minValue) {
    return minValue;
  }
  if (n > maxValue) {
    return maxValue;
  }
  return n;
}

int? getIntProp(dynamic value, String name, int minValue, int maxValue) {

  late int n;

  if (value is int) {
    n = value;
  } else if (value is String) {
    var parsedValue = int.tryParse(value);
    if (parsedValue == null) {
      logger.e('property "$name": cannot parse "$value" as an integer');
      return null;
    }
    n = parsedValue;
  } else {
    logger.e('property "$name": value is not an integer');
    return null;
  }

  if (n < minValue) {
    return minValue;
  }
  if (n > maxValue) {
    return maxValue;
  }
  return n;
}

bool? getBoolProp(dynamic value, String name) {

  late bool b;

  if (value is bool) {
    b = value;
  } else if (value is String) {
    var parsedValue = bool.tryParse(value);
    if (parsedValue == null) {
      logger.e('property "$name": cannot parse "$value" as a boolean');
      return null;
    }
    b = parsedValue;
  } else {
    logger.e('property "$name": value is not a boolean');
    return null;
  }

  return b;
}
