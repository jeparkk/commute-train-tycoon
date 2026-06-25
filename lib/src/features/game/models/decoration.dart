import 'dart:math';

import 'package:flutter/material.dart';

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
    return (baseCost * pow(1.62, currentLevel)).round();
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
  static const items = [
    DecorationItem(
      id: 'tiny_plant',
      slotKind: DecorationSlotKind.window,
      name: '작은 화분',
      assetId: 'tiny_plant',
      icon: Icons.local_florist_rounded,
      color: Color(0xFF7A9D54),
      baseCost: 140,
      incomePerLevel: 0.3,
      appealPerLevel: 16,
    ),
    DecorationItem(
      id: 'cat_doll',
      slotKind: DecorationSlotKind.window,
      name: '고양이 인형',
      assetId: 'cat_doll',
      icon: Icons.pets_rounded,
      color: Color(0xFFC27B65),
      baseCost: 360,
      incomePerLevel: 0.7,
      appealPerLevel: 34,
    ),
    DecorationItem(
      id: 'cheer_poster',
      slotKind: DecorationSlotKind.wall,
      name: '출근 응원 포스터',
      assetId: 'cheer_poster',
      icon: Icons.campaign_rounded,
      color: Color(0xFF5F8DC7),
      baseCost: 180,
      incomePerLevel: 0.4,
      appealPerLevel: 20,
    ),
    DecorationItem(
      id: 'route_map',
      slotKind: DecorationSlotKind.wall,
      name: '미니 노선도',
      assetId: 'route_map',
      icon: Icons.map_rounded,
      color: Color(0xFF7367A8),
      baseCost: 420,
      incomePerLevel: 0.8,
      appealPerLevel: 38,
    ),
    DecorationItem(
      id: 'soft_rug',
      slotKind: DecorationSlotKind.floor,
      name: '폭신 러그',
      assetId: 'soft_rug',
      icon: Icons.grid_view_rounded,
      color: Color(0xFFD2A84F),
      baseCost: 220,
      incomePerLevel: 0.5,
      appealPerLevel: 24,
    ),
    DecorationItem(
      id: 'lost_box',
      slotKind: DecorationSlotKind.floor,
      name: '분실물 박스',
      assetId: 'lost_box',
      icon: Icons.inventory_2_rounded,
      color: Color(0xFF4E9B8C),
      baseCost: 520,
      incomePerLevel: 1.0,
      appealPerLevel: 44,
    ),
  ];

  static DecorationItem byId(String id) {
    return items.firstWhere((item) => item.id == id);
  }

  static List<DecorationItem> forSlot(DecorationSlotKind slotKind) {
    return items.where((item) => item.slotKind == slotKind).toList();
  }
}
