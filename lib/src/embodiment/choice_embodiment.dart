// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// All rights reserved. Use of this source code is governed by the
// proprietary license that can be found in the LICENSE file.

import 'embodiment_help.dart';
import 'package:dartlib/dartlib.dart' as pg;
import 'package:dartlib/log.dart';
import 'package:flutter/material.dart';
import 'embodiment_manifest.dart';
import 'embodiment_args.dart';
import '../widgets/choice_field.dart';
import 'properties.dart';

EmbodimentPackageManifest getManifest() {
  return EmbodimentPackageManifest('Choice', [
    EmbodimentManifestEntry(
        'default', DefaultChoiceEmbodiment.fromArgs, ChoiceDefaultProperties.fromMap),
    EmbodimentManifestEntry(
        'button', ButtonChoiceEmbodiment.fromArgs, ChoiceDefaultProperties.fromMap),
  ]);
}

class DefaultChoiceEmbodiment extends StatelessWidget {
  const DefaultChoiceEmbodiment.fromArgs(this.args, {super.key});

  final EmbodimentArgs args;

  @override
  Widget build(BuildContext context) {
    var choice = args.primitive as pg.Choice;

    if (choice.collapsed) {
      return collapsedContent();
    }

    var props = args.properties as ChoiceDefaultProperties;

    var choiceLabels = choice.choiceLabels;
    var content = ChoiceField(
      choices: choice.choices,
      choiceLabels: choiceLabels.isNotEmpty ? choiceLabels : null,
      initialValue: choice.choice,
      onSubmitted: (value) {
        choice.choice = value;
      },
      textStyle: buildTextStyle(props),
      backgroundColor: props.backgroundColor,
    );

    return encloseWithPBMSAF(
      content,
      args,
      horizontalUnbounded: true,
      status: choice.status,
    );
  }
}

class ButtonChoiceEmbodiment extends StatefulWidget {
  ButtonChoiceEmbodiment.fromArgs(this.args, {super.key})
      : choice = args.primitive as pg.Choice;

  final EmbodimentArgs args;
  final pg.Choice choice;

  List<String> get choices {
    return choice.choices;
  }

  List<String> get choiceLabels {
    return choice.choiceLabels;
  }

  @override
  State<ButtonChoiceEmbodiment> createState() {
    return _ButtonChoiceEmbodimentState();
  }
}

class _ButtonChoiceEmbodimentState extends State<ButtonChoiceEmbodiment> {
  // Whether we are working with labels as choices.
  bool get usingLabels {
    return widget.choiceLabels.length == widget.choices.length;
  }

  // The "nominal" choices.  Althought these come directly from widget.choices, this field
  // makes the code a little cleaner looking.
  List<String> get nominalChoices {
    return widget.choices;
  }

  // The "effective" choices to work with.  These are either nominal choices from
  // widget.choices or widget.choiceLabels, depending on whether the labels are provided and
  // they correspond 1:1 with nominal choices.
  List<String> get workingChoices {
    if (usingLabels) {
      return widget.choiceLabels;
    } else {
      return nominalChoices;
    }
  }

  // Convert an nominal choice value to a working choice.
  String nominalToWorkingChoice(String choice) {
    // Short circuit...
    if (!usingLabels) {
      return choice;
    }
    int index = nominalChoices.indexOf(choice);
    return widget.choiceLabels[index];
  }

  // Convert a working choice to a nominal choice.
  String workingChoiceToNominal(String workingChoice) {
    // Short circuit...
    if (!usingLabels) {
      return workingChoice;
    }
    int index = workingChoices.indexOf(workingChoice);
    return nominalChoices[index];
  }

  void setCurrentChoice(String newChoice) {
    setState(() {
      widget.choice.choice = workingChoiceToNominal(newChoice);
    });
  }

  @override
  Widget build(BuildContext context) {
  
    if (widget.choice.collapsed) {
      return collapsedContent();
    }

    // Invalid choice?
    if (!widget.choice.isChoiceValid) {
      logger.e('choice "button" embodiment: the choice "${widget.choice}" not found in choices list');
      return errorWidget();
    }

    var props = widget.args.properties as ChoiceDefaultProperties;

    var choicesD = List<DropdownMenuItem<String>>.empty(growable: true);

    for (final element in workingChoices) {
      choicesD.add(DropdownMenuItem<String>(
        value: element,
        child: Text(element, style: buildTextStyle(props),),
      ));
    }

    var content = DropdownButton<String>(
      items: choicesD,
      value: nominalToWorkingChoice(widget.choice.choice),
      onChanged: (value) {
        if (value == null) return;
        setCurrentChoice(value);
      },
    );

    return encloseWithPBMSAF(
      content,
      widget.args,
      horizontalUnbounded: true,
      status: widget.choice.status,
    );
  }
}
