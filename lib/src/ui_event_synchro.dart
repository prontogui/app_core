// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.
//import 'dart:async';
import 'package:dartlib/dartlib.dart';
import 'package:dartlib/log.dart';

typedef UIEventHandler = void Function();

/// A model synchronizer that sends UI events to the server when certain fields are set.
class UIEventSynchro extends UpdateSynchro {
  UIEventSynchro({required PrimitiveLocator locator, this.comm})
      : super(locator, null, false, true);

  static Set<FKey> _eventFKeys() => const {
        fkeyChecked,
        fkeyChoice,
        fkeyCommandIssued,
        fkeyExpanded,
        fkeyExported,
        fkeyImported,
        fkeyIssued,
        fkeySelectedRows,
        fkeySelectionChanged,
        fkeySelectedItems,
        fkeyShowing,
        fkeyState,
        fkeyTextEntry,
        fkeyTimerFired
      };

  /// Optional CommClientData to send updates to the server.
  CommClientData? comm;

  @override
  void onFullModelUpdate() {
    clearPendingUpdates();
  }

  @override
  void onPartialModelUpdate() {
    clearPendingUpdates();
  }

  @override
  void onSetField(PKey pkey, FKey fkey, bool structural) {
    super.onSetField(pkey, fkey, structural);

    if (!_eventFKeys().contains(fkey)) {
      return;
    }

    logger.i(
        'handling onSetField post-filter with pkey: $pkey, fkey: $fkey (${fieldnameFor(fkey)}), structural: $structural');

    if (comm != null) {
      var cborUpdate = getPartialUpdate();
      logger.t('Sending CBOR update: $cborUpdate');
      comm!.submitUpdateToServer(cborUpdate);
    }

    clearPendingUpdates();
  }
}
