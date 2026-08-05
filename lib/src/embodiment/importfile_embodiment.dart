// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'embodiment_help.dart';
import 'package:dartlib/dartlib.dart' as pg;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'embodiment_manifest.dart';
import 'embodiment_args.dart';
import 'properties.dart';

EmbodimentPackageManifest getManifest() {
  return EmbodimentPackageManifest('ImportFile', [
    EmbodimentManifestEntry(
        'default', ImportFileEmbodiment.fromArgs, TextDefaultProperties.fromMap),
  ]);
}

class ImportFileEmbodiment extends StatelessWidget {
  const ImportFileEmbodiment.fromArgs(this.args, {super.key});

  final EmbodimentArgs args;

  @override
  Widget build(BuildContext context) {
    var importFile = args.primitive as pg.ImportFile;

    if (importFile.collapsed) {
      return collapsedContent();
    }

    var props = args.properties as TextDefaultProperties;

    var content = OutlinedButton(
        child: Text(
          "Select File",
          style: buildTextStyle(props),
        ),
        onPressed: () async {
          // TODO:  wait asyncrhonously for user to pick file and handle it
          // using a Future.
          FilePickerResult? result = await FilePicker.pickFiles(
              type: FileType.custom,
              allowedExtensions: importFile.validExtensions,
              dialogTitle: "Select file to import");

          if (result != null) {
            File file = File(result.files.single.path!);

            // TODO:  check the length against a maximum import size
            //var length = await file.length();

            // TODO:  read file asyncrhonously and use a Future to process data.
            file.readAsBytes().then((bytes) {
              importFile.importData(bytes, result.files.single.name);
            });
          }

          // Take Data and write to the file.
        });
    return encloseWithPBMSAF(
      content,
      args,
      status: importFile.status
    );
  }
}
