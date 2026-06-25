import 'dart:math';

import '../data/balance_config.dart';
import '../models/game_state.dart';

class OfflineRevenueCalculator {
  static const maxOfflineDuration = BalanceConfig.maxOfflineDuration;
  static const offlineEfficiency = BalanceConfig.offlineEfficiency;

  static Duration cappedDuration({
    required DateTime lastSavedAt,
    required DateTime now,
    Duration maxDuration = maxOfflineDuration,
  }) {
    final elapsed = now.difference(lastSavedAt);
    if (elapsed.isNegative) {
      return Duration.zero;
    }

    return Duration(seconds: min(elapsed.inSeconds, maxDuration.inSeconds));
  }

  static int calculate({required GameState state, required DateTime now}) {
    final maxDuration = state.monetization.vipPassActive
        ? BalanceConfig.vipOfflineDuration
        : maxOfflineDuration;
    final capped = cappedDuration(
      lastSavedAt: state.lastSavedAt,
      now: now,
      maxDuration: maxDuration,
    );
    if (capped.inSeconds < 10) {
      return 0;
    }

    return (state.baseIncomePerSecond * capped.inSeconds * offlineEfficiency)
        .floor();
  }
}
