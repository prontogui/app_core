// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// All rights reserved. Use of this source code is governed by the
// proprietary license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';

// Unfortunately, the class ChangeNotifier must be subclassed to call notifyListeners method.  Crazy, huh?
class Notifier extends ChangeNotifier {
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
