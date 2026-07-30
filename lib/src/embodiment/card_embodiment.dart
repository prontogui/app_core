// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// All rights reserved. Use of this source code is governed by the
// proprietary license that can be found in the LICENSE file.

import '../embodifier.dart';
import 'package:dartlib/dartlib.dart' as pg;
import 'package:dartlib/log.dart';
import 'package:flutter/material.dart';
import 'embodiment_manifest.dart';
import 'embodiment_args.dart';
import 'embodiment_help.dart';
import 'properties.dart';

EmbodimentPackageManifest getManifest() {
  return EmbodimentPackageManifest('Card', [
    EmbodimentManifestEntry(
        'default', CardDefaultEmbodiment.fromArgs, CommonProperties.fromMap),
    EmbodimentManifestEntry(
        'tile', CardTileEmbodiment.fromArgs, CommonProperties.fromMap),
  ]);
}

class CardDefaultEmbodiment extends StatelessWidget {
  const CardDefaultEmbodiment.fromArgs(this.args, {super.key});

  final EmbodimentArgs args;

  @override
  Widget build(BuildContext context) {

    var card = args.primitive as pg.Card;
    if (card.collapsed) {
      return collapsedContent();
    }

    var content = Card.outlined(
      child: _buildTile(context, args),
    );

    return encloseWithPBMSAF(
      content,
      args,
      status: card.status,
    );
  }
}

class CardTileEmbodiment extends StatelessWidget {
  const CardTileEmbodiment.fromArgs(this.args, {super.key});

  final EmbodimentArgs args;

  @override
  Widget build(BuildContext context) {

    var card = args.primitive as pg.Card;
    if (card.collapsed) {
      return collapsedContent();
    }

    var content = _buildTile(context, args);
    return encloseWithPBMSAF(
      content,
      args,
      status: card.status,
    );
  }
}

// The allowed primitives for the leading item.
const Set<String> _allowedTypesForLeadingItem = {
  'Check',
  'Command',
  'Icon',
  'Image',
  'Nothing',
  'Text',
  'Tristate',
};

// The allowed primitives for the main item.
const Set<String> _allowedTypesForMainItem = {
  'Text',
  'Nothing',
};

// The allowed primitives for the sub item.
const Set<String> _allowedTypesForSubItem = {
  'Text',
  'Nothing',
};

// The allowed primitives for the trailing item.
const Set<String> _allowedTypesForTrailingItem = {
  'Check',
  'Choice',
  'Command',
  'Icon',
  'Image',
  'Nothing',
  'Text',
  'Tristate',
};

Widget _buildTile(BuildContext context, EmbodimentArgs args) {
  var card = args.primitive as pg.Card;
  var embodifier = InheritedEmbodifier.of(context);

  var modelPrimitive = args.modelPrimitive;

  pg.Card? modelCard;
  if (modelPrimitive != null && modelPrimitive is pg.Card) {
    modelCard = modelPrimitive;
  }

  var leading = _embodifySingleItem(context, embodifier, card.leadingItem,
      modelCard?.leadingItem, _allowedTypesForLeadingItem, 'leading');
  var title = _embodifySingleItem(context, embodifier, card.mainItem,
      modelCard?.mainItem, _allowedTypesForMainItem, 'title',
      defaultWidget: SizedBox.shrink());
  var sub = _embodifySingleItem(context, embodifier, card.subItem,
      modelCard?.subItem, _allowedTypesForSubItem, 'sub');
  var trailing = _embodifySingleItem(context, embodifier, card.trailingItem,
      modelCard?.trailingItem, _allowedTypesForTrailingItem, 'trailing');

  // If callbacks are available, then handle selection state
  var selected = false;
  void Function()? handleTap;
  if (args.callbacks != null) {
    var cb = args.callbacks!;

    // If List selection is available...
    if (cb.isSelected != null) {
      selected = cb.isSelected!(cb.indexes);
    }
    if (cb.onSelection != null) {
      handleTap = () {
        cb.onSelection!(cb.indexes);
      };
    }
  }

  return ListTile(
    leading: leading,
    title: title,
    subtitle: sub,
    trailing: trailing,
    selected: selected,
    onTap: handleTap,
  );
}

Widget? _embodifySingleItem(BuildContext context, Embodifier embodifier,
    pg.Primitive? item, pg.Primitive? modelItem, Set<String> allowedTypes, String itemName,
    {Widget? defaultWidget}) {
  if (item == null) {
    return defaultWidget;
  }
  // Only certain primitives are supported
  if (!allowedTypes.contains(item.describeType)) {
    logger.e('card "tile" embodiment: the card item $itemName is of type "${item.describeType}" which is not supported');
    return errorWidget();
  }

  return embodifier.buildPrimitive(context, item,
      modelPrimitive: modelItem, noEnclosures: true);
}
