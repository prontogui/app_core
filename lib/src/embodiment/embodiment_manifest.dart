// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:app_core/src/embodiment/properties.dart';
import 'package:flutter/material.dart';
import 'embodiment_args.dart';

class EmbodimentManifestEntry {
  EmbodimentManifestEntry(
      this.embodiment, this.factoryFunction, this.propertyAccess,
      {this.keyRequired = false});

  final String embodiment;
  final Widget Function(EmbodimentArgs, {Key? key}) factoryFunction;
  final Properties Function(Map<String, dynamic>? embodimentMap,
      {Properties? initialProperties}) propertyAccess;
  final bool keyRequired;
}

class EmbodimentPackageManifest {
  EmbodimentPackageManifest(this.primitiveType, this.entries);

  final String primitiveType;
  final List<EmbodimentManifestEntry> entries;
}
