// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// All rights reserved. Use of this source code is governed by the
// proprietary license that can be found in the LICENSE file.
import 'package:app_core/src/embodiment/properties.dart';
import 'package:dartlib/dartlib.dart' as pg;
import 'package:flutter/material.dart';
import 'dart:async';
import 'embodiment_manifest.dart';
import 'embodiment_args.dart';

EmbodimentPackageManifest getManifest() {
  return EmbodimentPackageManifest('Timer', [
    EmbodimentManifestEntry(
        'default', TimerEmbodiment.fromArgs, NothingProperties.fromMap),
  ]);
}

class TimerEmbodiment extends StatefulWidget {
  TimerEmbodiment.fromArgs(this.args, {super.key})
      : timer = args.primitive as pg.Timer;

  final EmbodimentArgs args;
  final pg.Timer timer;

  @override
  State<TimerEmbodiment> createState() => _TimerEmbodimentState();
}

class _TimerEmbodimentState extends State<TimerEmbodiment> {
  Timer? timer;
  //int _ticks = 0;

  void cancelTimer() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
  }

  void configureTimer() {
    var periodMs = widget.timer.periodMs;

    cancelTimer();

    if (periodMs < 0) {
      // Timer = null
    } else if (periodMs == 0) {
      // Timer = null
      // Fire the timer once only
      widget.timer.fireTimer();
    } else {
      // Fire the timer periodically
      timer = Timer.periodic(Duration(milliseconds: periodMs), (Timer _) {
        // NO NEED TO WRAP IN setState AT THIS TIME.  MAYBE LATER IF WE
        // RENDER THE TIMER IN SOME WAY.
//        setState(() {
        widget.timer.fireTimer();
//        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    configureTimer();
  }

  @override
  void didUpdateWidget(TimerEmbodiment oldWidget) {
    super.didUpdateWidget(oldWidget);
    configureTimer();
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Timer shows nothing by default.
    return const SizedBox();
  }
}
