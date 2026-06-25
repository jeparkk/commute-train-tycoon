import 'dart:math';

import 'slot_kind.dart';

class UpgradeSlot {
  const UpgradeSlot({
    required this.kind,
    required this.level,
    required this.baseCost,
    required this.baseIncome,
  });

  final SlotKind kind;
  final int level;
  final int baseCost;
  final double baseIncome;

  int get nextCost => (baseCost * pow(1.72, level - 1)).round();
  double get incomePerSecond => baseIncome * level;
  bool get isMaxed => level >= 20;

  UpgradeSlot levelUp() {
    return UpgradeSlot(
      kind: kind,
      level: level + 1,
      baseCost: baseCost,
      baseIncome: baseIncome,
    );
  }
}
