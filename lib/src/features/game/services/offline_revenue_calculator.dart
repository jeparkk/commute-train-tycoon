import 'dart:math';

import '../models/game_state.dart';

class OfflineRevenueCalculator {
  static const maxOfflineDuration = Duration(hours: 6);
  static const offlineEfficiency = 0.35;

  static int calculate({required GameState state, required DateTime now}) {
    final elapsed = now.difference(state.lastSavedAt);
    if (elapsed.isNegative || elapsed.inSeconds < 10) {
      return 0;
    }

    final cappedSeconds = min(elapsed.inSeconds, maxOfflineDuration.inSeconds);

    return (state.baseIncomePerSecond * cappedSeconds * offlineEfficiency)
        .floor();
  }
}
