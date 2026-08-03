// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:dartlib/dartlib.dart';
import 'package:dartlib/log.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../embodifier.dart';
import '../global_windows.dart';
import '../inherited_comm.dart';
import '../inherited_primitive_model.dart';
import '../ui_builder_synchro.dart';
import '../ui_event_synchro.dart';
import '../window/window_management.dart';

const _kConfigureWindowMessage = 'configure_window';

const _menuChannel = MethodChannel('com.prontogui.core/menu');

/// Native-side (macOS only) registration channel used to tell
/// `AppDelegate` that this engine is the instance window, so it should
/// rebind the shared native menu bar's actions to this engine. See
/// `macos/Runner/AppDelegate.swift`'s `registerEngineForMenu`.
const _menuRegistrationChannel = MethodChannel('com.prontogui.core/menu_registration');

/// Wires up the model, gRPC comm, embodifier, event/builder synchros,
/// menu handler, and the inherited-widget tree, then calls [runApp].
///
/// Call this from `main()` once the engine has been determined to be
/// an instance-window engine (i.e. neither a global window nor a gate
/// window). The function is one-shot: it owns the objects it creates
/// and they live for the lifetime of the engine.
/// [topBanner], when supplied, is forwarded to `App.remote` and rendered
/// above the main content — e.g. an app that layers licensing on top of
/// this package can pass its own "no license installed" banner here. The
/// widget is responsible for updating itself (e.g. by listening to
/// [WindowManagement.notifyLicenseInfoUpdated] internally); this function
/// and `App` don't rebuild it themselves.
void runInstanceWindowApp({
  required WindowManagement windowManagement,
  Widget? topBanner,
}) {
  // Holds the primitives the server has sent for this window to render.
  final model = PrimitiveModel();

  // Notifies UI when the gRPC connection state changes.
  final commNotifier = CommClientChangeNotifier();

  // Talks to the ProntoGUI server.
  final grpcComm = GrpcCommClient(
    onStateChange: () => commNotifier.onStateChange(),
    serverCheckinPeriod: 0,
  );

  // Feed CBOR updates from the server into the model.
  grpcComm.updatesFromServer.listen(
    (cborUpdate) {
      logger.t('Received CBOR update.');
      try {
        model.ingestCborUpdate(cborUpdate);
      } catch (e) {
        logger.e('Error ingesting CBOR update: $e');
      }
    },
    onError: (e) {
      logger.e(e.toString());
      model.topPrimitives = [];
    },
  );

  // Tear down the gRPC connection when this window closes or when a
  // configure-window message arrives (the user is reconnecting).
  windowManagement.notifyOurWindowClosed.addListener(() {
    grpcComm.close();
  });
  windowManagement.notifyMessageToOurWindow.addListener(() {
    switch (windowManagement.notifyMessageToOurWindow.arg) {
      case _kConfigureWindowMessage:
        grpcComm.close();
    }
  });

  // Belt-and-suspenders gRPC teardown for clean shutdown: if a sibling
  // engine triggered shutdown, this engine's window was never X'd, so
  // `notifyOurWindowClosed` never fired and grpcComm would otherwise
  // get yanked by `exit(0)` instead of closed. `close()` is idempotent.
  ShutdownCoordinator.instance.addCleanup(() async => grpcComm.close());

  commNotifier.comm = grpcComm;

  // Embodies the model as widgets and rebuilds the UI on model changes.
  final embodifier = Embodifier();

  // Sends UI events back to the server.
  final eventSynchro = UIEventSynchro(locator: model, comm: grpcComm);

  // Rebuilds whole-tree or partial-tree UI in response to model changes.
  final builderSynchro = UIBuilderSynchro(embodifier);

  // Notifies subtrees on full-model and top-level-primitive changes.
  final fullUpdateNotifier =
      PrimitiveModelChangeNotifier(model: model, notifyOnFull: true);
  final topLevelUpdateNotifier =
      PrimitiveModelChangeNotifier(model: model, notifyOnTopLevel: true);

  model.addWatcher(embodifier);
  model.addWatcher(fullUpdateNotifier);
  model.addWatcher(topLevelUpdateNotifier);
  model.addWatcher(eventSynchro);
  model.addWatcher(builderSynchro);

  // Open the comm channel if the saved settings have a host configured.
  if (windowManagement.settings.host.isNotEmpty) {
    grpcComm.open(
      serverAddress: windowManagement.settings.host,
      serverPort: windowManagement.settings.port,
    );
  }

  // First instance window in the process registers the menu handler;
  // subsequent windows can't register since the channel is process-wide.
  _menuHandler(windowManagement);
  _claimNativeMenuTarget();

  runApp(InheritedCommClient(
    notifier: commNotifier,
    child: InheritedPrimitiveModel(
      notifier: fullUpdateNotifier,
      child: InheritedTopLevelPrimitives(
        notifier: topLevelUpdateNotifier,
        child: InheritedEmbodifier(
          embodifier: embodifier,
          child: App.remote(topBanner: topBanner),
        ),
      ),
    ),
  ));
}

/// Tells the macOS native side that this engine is the instance window,
/// so `AppDelegate` rebinds the shared native menu bar's actions to it.
///
/// Needed because the primary engine isn't always the instance window —
/// on first launch it's the EULA gate window instead (see
/// `StartupSequence` / `main.dart`), and `AppDelegate` used to bind the
/// menu channel once, statically, to whichever window existed at app
/// launch. That left the real instance window (spun up afterward in a
/// separate engine once the EULA is accepted) unable to receive native
/// menu clicks until the app was relaunched. No-op on Windows/Linux,
/// which render an in-Flutter menu bar (`WindowMenuBar`) instead of a
/// native one and don't implement this channel.
void _claimNativeMenuTarget() {
  if (defaultTargetPlatform != TargetPlatform.macOS) return;
  _menuRegistrationChannel.invokeMethod('claimTarget');
}

void _menuHandler(WindowManagement windowManagement) {
  _menuChannel.setMethodCallHandler((call) async {
    switch (call.method) {
      case 'menu.about':
        logger.t('Menu item request: About');
        windowManagement.openGlobalWindow(kAboutWindowKey);
        break;
      case 'menu.checkForUpdates':
        logger.t('Menu item request: Check For Updates');
        break;
      case 'menu.settings':
        logger.t('Menu item request: Settings');
        windowManagement.openGlobalWindow(kSettingsWindowKey);
        break;
      case 'menu.showLog':
        logger.t('Menu item request: Show Log');
        windowManagement.openGlobalWindow(kLogWindowKey);
        break;
      case 'menu.developerDocumentation':
        logger.t('Menu item request: Developer Documentation');
        launchUrl(Uri.parse('https://prontogui.com/support/'));
        break;
      case 'menu.releaseNotes':
        logger.t('Menu item request: Release Notes');
        launchUrl(Uri.parse('https://prontogui.com/support/release-notes/'));
        break;
      case 'menu.provideFeedback':
        logger.t('Menu item request: Provide Feedback');
        launchUrl(Uri.parse('https://prontogui.com/contact-us/'));
        break;
      case 'menu.newWindow':
        logger.t('Menu item request: New Window');
        windowManagement.newInstanceWindow();
        break;
      case 'menu.configureWindow':
        logger.t('Menu item request: Configure Window');
        await windowManagement.sendMessageToFocusedInstanceWindow(_kConfigureWindowMessage);
        break;
      case 'menu.closeWindow':
        logger.t('Menu item request: Close Window');
        await windowManagement.closeFocusedInstanceWindow();
        break;
      default:
        logger.e('Unknown menu action: ${call.method}');
    }
  });
}
