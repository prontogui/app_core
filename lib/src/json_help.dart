
String dateToString(DateTime? date) {
  if (date == null) {
    return '';
  }

  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class JSONFieldDecoder {
  JSONFieldDecoder(this.data);
    
  Map<String, dynamic> data;

  // Helper function for parsing integers
  double? asDouble(String propertyName) {
    final value = data[propertyName];
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final d = double.tryParse(value);
      if (d != null) {
        return d;
      }
    }
    return null;
  }

  // Helper function for parsing integers
  int asInt(String propertyName, int def) {
    final value = data[propertyName];
    if (value == null) {
      return def;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? def;
    }
    return def;
  }

  // Helper function for parsing booleans.
  bool asBool(String propertyName, bool def) {
    final value = data[propertyName];
    if (value == null) {
      return def;
    }
    if (value is bool) {
      return value;
    }
    return def;
  }

  // Helper function for parsing strings
  String asString(String propertyName, String def) {
    final value= data[propertyName];
    if (value == null) {
      return def;
    }
    if (value is String) {
      return value;
    }
    return def;
  }

  // Helper function for parsing strings
  DateTime? asDateTime(String propertyName) {
    final value= data[propertyName];
    if (value == null) {
      return null;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  // Helper function for parsing enums.
  E asEnum<E extends Enum>(String propertyName, List<E> values, E def,
  ) {
    final raw = data[propertyName];
    if (raw == null) {
      return def;
    }
    if (raw is String) {
      return values.firstWhere(
        (value) => value.name == raw,
        orElse: () => def,
      );
    }
    return def;
  }

  // Helper function for parsing maps
  Map<String, dynamic>? asMap(String propertyName, Map<String, dynamic>? def) {
    final value= data[propertyName];
    if (value == null) {
      return def;
    }
    if (value is Map<String, dynamic>) {
      return value;
    }
    return def;
  }
}
