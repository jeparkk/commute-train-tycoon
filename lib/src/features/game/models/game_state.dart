import 'decoration.dart';
import 'slot_kind.dart';
import 'upgrade_slot.dart';

class GameState {
  const GameState({
    required this.gold,
    required this.slots,
    required this.decorations,
    required this.lastSavedAt,
    required this.pendingOfflineGold,
    required this.focusBoostEnabled,
  });

  factory GameState.initial(DateTime now) {
    return GameState(
      gold: 180,
      slots: const {
        SlotKind.seat: UpgradeSlot(
          kind: SlotKind.seat,
          level: 1,
          baseCost: 80,
          baseIncome: 0.8,
        ),
        SlotKind.kiosk: UpgradeSlot(
          kind: SlotKind.kiosk,
          level: 1,
          baseCost: 120,
          baseIncome: 1.1,
        ),
      },
      decorations: const {
        DecorationSlotKind.window: null,
        DecorationSlotKind.wall: null,
        DecorationSlotKind.floor: null,
      },
      lastSavedAt: now,
      pendingOfflineGold: 0,
      focusBoostEnabled: true,
    );
  }

  final double gold;
  final Map<SlotKind, UpgradeSlot> slots;
  final Map<DecorationSlotKind, PlacedDecoration?> decorations;
  final DateTime lastSavedAt;
  final int pendingOfflineGold;
  final bool focusBoostEnabled;

  double get baseIncomePerSecond {
    final slotIncome = slots.values.fold<double>(
      0,
      (sum, slot) => sum + slot.incomePerSecond,
    );
    final decorationIncome = decorations.values
        .whereType<PlacedDecoration>()
        .fold<double>(0, (sum, placed) {
          final item = DecorationCatalog.byId(placed.itemId);
          return sum + item.incomePerLevel * placed.level;
        });

    return slotIncome + decorationIncome;
  }

  double get activeIncomePerSecond {
    return baseIncomePerSecond * (focusBoostEnabled ? 2 : 1);
  }

  int get trainAppeal {
    final slotAppeal = slots.values.fold<int>(
      0,
      (sum, slot) => sum + slot.level * 12,
    );
    final decorationAppeal = decorations.values
        .whereType<PlacedDecoration>()
        .fold<int>(0, (sum, placed) {
          final item = DecorationCatalog.byId(placed.itemId);
          return sum + item.appealPerLevel * placed.level;
        });

    return slotAppeal + decorationAppeal;
  }

  int get placedDecorationCount {
    return decorations.values.whereType<PlacedDecoration>().length;
  }

  GameState copyWith({
    double? gold,
    Map<SlotKind, UpgradeSlot>? slots,
    Map<DecorationSlotKind, PlacedDecoration?>? decorations,
    DateTime? lastSavedAt,
    int? pendingOfflineGold,
    bool? focusBoostEnabled,
  }) {
    return GameState(
      gold: gold ?? this.gold,
      slots: slots ?? this.slots,
      decorations: decorations ?? this.decorations,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      pendingOfflineGold: pendingOfflineGold ?? this.pendingOfflineGold,
      focusBoostEnabled: focusBoostEnabled ?? this.focusBoostEnabled,
    );
  }
}
