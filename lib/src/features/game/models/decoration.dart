import 'dart:math';

import 'package:flutter/material.dart';

import '../data/balance_config.dart';

enum DecorationSlotKind {
  window('창가', Icons.window_rounded),
  wall('벽면', Icons.image_rounded),
  floor('바닥', Icons.layers_rounded);

  const DecorationSlotKind(this.label, this.icon);

  final String label;
  final IconData icon;
}

class DecorationItem {
  const DecorationItem({
    required this.id,
    required this.slotKind,
    required this.name,
    required this.assetId,
    required this.icon,
    required this.color,
    required this.baseCost,
    required this.incomePerLevel,
    required this.appealPerLevel,
  });

  final String id;
  final DecorationSlotKind slotKind;
  final String name;
  final String assetId;
  final IconData icon;
  final Color color;
  final int baseCost;
  final double incomePerLevel;
  final int appealPerLevel;

  int costForLevel(int currentLevel) {
    return (baseCost * pow(BalanceConfig.decorationCostGrowth, currentLevel))
        .round();
  }
}

class PlacedDecoration {
  const PlacedDecoration({required this.itemId, required this.level});

  final String itemId;
  final int level;

  PlacedDecoration levelUp() {
    return PlacedDecoration(itemId: itemId, level: level + 1);
  }
}

class DecorationCatalog {
  static final items = BalanceConfig.decorations
      .map(
        (balance) => DecorationItem(
          id: balance.id,
          slotKind: balance.slotKind,
          name: balance.name,
          assetId: balance.assetId,
          icon: balance.icon,
          color: balance.color,
          baseCost: balance.baseCost,
          incomePerLevel: balance.incomePerLevel,
          appealPerLevel: balance.appealPerLevel,
        ),
      )
      .toList(growable: false);

  static DecorationItem byId(String id) {
    return items.firstWhere((item) => item.id == id);
  }

  static List<DecorationItem> forSlot(DecorationSlotKind slotKind) {
    return items.where((item) => item.slotKind == slotKind).toList();
  }
}
