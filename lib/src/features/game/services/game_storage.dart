import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/decoration.dart';
import '../models/game_state.dart';
import '../models/movement_report.dart';
import '../models/offline_reward.dart';
import '../models/slot_kind.dart';
import '../models/upgrade_slot.dart';
import 'offline_revenue_calculator.dart';

class GameStorage {
  static const _goldKey = 'gold';
  static const _warpPointsKey = 'warpPoints';
  static const _lastSavedAtKey = 'lastSavedAt';
  static const _focusBoostKey = 'focusBoostEnabled';
  static const _lastMoveDistanceKey = 'lastMoveDistanceKm';
  static const _lastMoveDurationKey = 'lastMoveDurationSeconds';
  static const _lastMoveGoldKey = 'lastMoveGold';
  static const _lastMoveWarpPointsKey = 'lastMoveWarpPoints';
  static const _lastMoveMultiplierKey = 'lastMoveMultiplier';
  static const _lastMoveSettledAtKey = 'lastMoveSettledAt';
  static const _lastMoveSourceKey = 'lastMoveSource';

  static String _levelKey(SlotKind kind) => '${kind.name}Level';
  static String _decorationItemKey(DecorationSlotKind kind) =>
      '${kind.name}DecorationItem';
  static String _decorationLevelKey(DecorationSlotKind kind) =>
      '${kind.name}DecorationLevel';

  Future<GameState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final base = GameState.initial(now);

    final lastSavedMillis = prefs.getInt(_lastSavedAtKey);
    final lastSavedAt = lastSavedMillis == null
        ? now
        : DateTime.fromMillisecondsSinceEpoch(lastSavedMillis);

    final slots = {
      for (final entry in base.slots.entries)
        entry.key: UpgradeSlot(
          kind: entry.value.kind,
          level: max(
            1,
            prefs.getInt(_levelKey(entry.key)) ?? entry.value.level,
          ),
          baseCost: entry.value.baseCost,
          baseIncome: entry.value.baseIncome,
        ),
    };
    final decorations = {
      for (final slotKind in DecorationSlotKind.values)
        slotKind: _loadDecoration(prefs, slotKind),
    };

    final storedGold = prefs.getDouble(_goldKey) ?? base.gold;
    final storedWarpPoints = prefs.getInt(_warpPointsKey) ?? base.warpPoints;
    final focusBoostEnabled = prefs.getBool(_focusBoostKey) ?? true;
    final loaded = base.copyWith(
      gold: storedGold,
      warpPoints: storedWarpPoints,
      slots: slots,
      decorations: decorations,
      lastSavedAt: lastSavedAt,
      lastMovementReport: _loadMovementReport(prefs),
      focusBoostEnabled: focusBoostEnabled,
    );

    final offlineDuration = OfflineRevenueCalculator.cappedDuration(
      lastSavedAt: loaded.lastSavedAt,
      now: now,
    );
    final offlineGold = OfflineRevenueCalculator.calculate(
      state: loaded,
      now: now,
    );
    final checkpoint = offlineGold > 0 ? loaded.lastSavedAt : now;

    return loaded.copyWith(
      lastSavedAt: checkpoint,
      pendingOfflineGold: offlineGold,
      offlineReward: OfflineReward(
        gold: offlineGold,
        duration: offlineDuration,
        maxDuration: OfflineRevenueCalculator.maxOfflineDuration,
        efficiency: OfflineRevenueCalculator.offlineEfficiency,
      ),
    );
  }

  Future<void> save(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_goldKey, state.gold);
    await prefs.setInt(_warpPointsKey, state.warpPoints);
    await prefs.setInt(
      _lastSavedAtKey,
      state.lastSavedAt.millisecondsSinceEpoch,
    );
    await prefs.setBool(_focusBoostKey, state.focusBoostEnabled);

    for (final entry in state.slots.entries) {
      await prefs.setInt(_levelKey(entry.key), entry.value.level);
    }

    for (final entry in state.decorations.entries) {
      final placed = entry.value;
      if (placed == null) {
        await prefs.remove(_decorationItemKey(entry.key));
        await prefs.remove(_decorationLevelKey(entry.key));
      } else {
        await prefs.setString(_decorationItemKey(entry.key), placed.itemId);
        await prefs.setInt(_decorationLevelKey(entry.key), placed.level);
      }
    }

    await _saveMovementReport(prefs, state.lastMovementReport);
  }

  PlacedDecoration? _loadDecoration(
    SharedPreferences prefs,
    DecorationSlotKind slotKind,
  ) {
    final itemId = prefs.getString(_decorationItemKey(slotKind));
    if (itemId == null || !DecorationCatalog.items.any((i) => i.id == itemId)) {
      return null;
    }

    final item = DecorationCatalog.byId(itemId);
    if (item.slotKind != slotKind) {
      return null;
    }

    return PlacedDecoration(
      itemId: itemId,
      level: max(1, prefs.getInt(_decorationLevelKey(slotKind)) ?? 1),
    );
  }

  MovementReport _loadMovementReport(SharedPreferences prefs) {
    final settledAtMillis = prefs.getInt(_lastMoveSettledAtKey);
    if (settledAtMillis == null) {
      return const MovementReport.empty();
    }

    final sourceName = prefs.getString(_lastMoveSourceKey);
    final source = MovementRewardSource.values.firstWhere(
      (value) => value.name == sourceName,
      orElse: () => MovementRewardSource.demo,
    );

    return MovementReport(
      distanceKm: prefs.getDouble(_lastMoveDistanceKey) ?? 0,
      duration: Duration(seconds: prefs.getInt(_lastMoveDurationKey) ?? 0),
      gold: prefs.getInt(_lastMoveGoldKey) ?? 0,
      warpPoints: prefs.getInt(_lastMoveWarpPointsKey) ?? 0,
      multiplier: prefs.getDouble(_lastMoveMultiplierKey) ?? 1,
      settledAt: DateTime.fromMillisecondsSinceEpoch(settledAtMillis),
      source: source,
    );
  }

  Future<void> _saveMovementReport(
    SharedPreferences prefs,
    MovementReport report,
  ) async {
    if (!report.hasReward || report.settledAt == null) {
      await prefs.remove(_lastMoveDistanceKey);
      await prefs.remove(_lastMoveDurationKey);
      await prefs.remove(_lastMoveGoldKey);
      await prefs.remove(_lastMoveWarpPointsKey);
      await prefs.remove(_lastMoveMultiplierKey);
      await prefs.remove(_lastMoveSettledAtKey);
      await prefs.remove(_lastMoveSourceKey);
      return;
    }

    await prefs.setDouble(_lastMoveDistanceKey, report.distanceKm);
    await prefs.setInt(_lastMoveDurationKey, report.duration.inSeconds);
    await prefs.setInt(_lastMoveGoldKey, report.gold);
    await prefs.setInt(_lastMoveWarpPointsKey, report.warpPoints);
    await prefs.setDouble(_lastMoveMultiplierKey, report.multiplier);
    await prefs.setInt(
      _lastMoveSettledAtKey,
      report.settledAt!.millisecondsSinceEpoch,
    );
    await prefs.setString(_lastMoveSourceKey, report.source.name);
  }
}
