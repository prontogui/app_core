// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:dartlib/dartlib.dart' as pg;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'embodiment_manifest.dart';
import 'embodiment_args.dart';
import 'properties.dart';
import 'embodiment_help.dart';

EmbodimentPackageManifest getManifest() {
  return EmbodimentPackageManifest('ExportFile', [
    EmbodimentManifestEntry(
        'default', ExportFileEmbodiment.fromArgs, TextDefaultProperties.fromMap),
  ]);
}

class ExportFileEmbodiment extends StatelessWidget {
  const ExportFileEmbodiment.fromArgs(
    this.args, {
    super.key,
  });

  final EmbodimentArgs args;

  @override
  Widget build(BuildContext context) {
    var exportFile = args.primitive as pg.ExportFile;

    if (exportFile.collapsed) {
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
          var saveTo = await FilePicker.saveFile(
              fileName: exportFile.name.toString(),
              dialogTitle: "Select location to export PDF file to");

          if (saveTo != null) {
            File file = File(saveTo);

            // TODO:  write file asyncrhonously and use a Future to process data.
            await file.writeAsBytes(exportFile.data);

            exportFile.exported = true;
          }

          // Take Data and write to the file.
        });
    return encloseWithPBMSAF(
      content,
      args,
      status: exportFile.status
    );
  }
}
