// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// Returns a platform-specific machine identifier, or null if unsupported.
///
/// Used anywhere a persisted record needs to detect "this blob was copied
/// from another machine" — e.g. `EulaAcceptance` in this package, and
/// license activation state in apps that layer licensing on top of it.
abstract class MachineIdProvider {
  Future<String?> getMachineId();
}

/// Production implementation — uses device_info_plus to obtain a stable
/// hardware ID on Windows, macOS, or Linux.
class DeviceMachineIdProvider implements MachineIdProvider {
  @override
  Future<String?> getMachineId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isWindows) {
      return (await deviceInfo.windowsInfo).deviceId;
    } else if (Platform.isMacOS) {
      return (await deviceInfo.macOsInfo).systemGUID;
    } else if (Platform.isLinux) {
      return (await deviceInfo.linuxInfo).machineId;
    }

    return null;
  }
}
