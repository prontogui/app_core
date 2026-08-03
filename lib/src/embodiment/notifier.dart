// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:flutter/foundation.dart';

// Unfortunately, the class ChangeNotifier must be subclassed to call notifyListeners method.  Crazy, huh?
class Notifier extends ChangeNotifier {
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
