import 'package:flutter/material.dart';

import '../models/decoration.dart';
import '../models/slot_kind.dart';

class BalanceConfig {
  const BalanceConfig._();

  static const startingGold = 180.0;
  static const slotCostGrowth = 1.72;
  static const decorationCostGrowth = 1.62;
  static const maxSlotLevel = 20;
  static const maxDecorationLevel = 10;
  static const appealPerSlotLevel = 12;
  static const maxOfflineDuration = Duration(hours: 6);
  static const offlineEfficiency = 0.35;

  static const slots = {
    SlotKind.seat: SlotBalance(
      kind: SlotKind.seat,
      baseCost: 80,
      baseIncome: 0.8,
    ),
    SlotKind.kiosk: SlotBalance(
      kind: SlotKind.kiosk,
      baseCost: 120,
      baseIncome: 1.1,
    ),
  };

  static const decorations = [
    DecorationBalance(
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
    DecorationBalance(
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
    DecorationBalance(
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
    DecorationBalance(
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
    DecorationBalance(
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
    DecorationBalance(
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
}

class SlotBalance {
  const SlotBalance({
    required this.kind,
    required this.baseCost,
    required this.baseIncome,
  });

  final SlotKind kind;
  final int baseCost;
  final double baseIncome;
}

class DecorationBalance {
  const DecorationBalance({
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
}
