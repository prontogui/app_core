// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:dartlib/log.dart';
import 'package:flutter/foundation.dart';

import '../cmd_line_options.dart';

/// Initializes file-backed logging for this engine and sets the
/// process-wide [loggingLevel] for the [logger].
///
/// Logs are grouped under [windowKey] so each window's events land in
/// its own file. The level is taken from [args] in debug-but-overridden
/// to `debug` in dev builds and clamped to `warning` in release. This
/// matches the prior inline behavior in `main()`.
Future<void> configureLogging(List<String> args, String windowKey) async {
  await initializeLogging(logGroup: windowKey);

  assert(() {
    // ignore: avoid_print
    print('Log files are stored at: $logsPath');
    return true;
  }());

  final options = CmdLineOptions.from(args);
  loggingLevel = options.logLevel;

  if (kDebugMode) {
    loggingLevel = LoggingLevel.debug;
  } else {
    loggingLevel = LoggingLevel.warning;
  }
}
