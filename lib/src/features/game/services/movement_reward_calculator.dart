import '../data/balance_config.dart';
import '../models/movement_report.dart';

class MovementRewardCalculator {
  const MovementRewardCalculator._();

  static MovementReport demoCommute({required bool screenOnBoost}) {
    return calculate(
      distanceKm: 7.2,
      duration: const Duration(minutes: 26),
      screenOnBoost: screenOnBoost,
      source: MovementRewardSource.demo,
      settledAt: DateTime.now(),
    );
  }

  static MovementReport calculate({
    required double distanceKm,
    required Duration duration,
    required bool screenOnBoost,
    required MovementRewardSource source,
    required DateTime settledAt,
  }) {
    final safeDistance = distanceKm.clamp(0, 100).toDouble();
    final multiplier = screenOnBoost
        ? BalanceConfig.movementScreenOnMultiplier
        : 1.0;

    return MovementReport(
      distanceKm: safeDistance,
      duration: duration,
      gold: (safeDistance * BalanceConfig.movementGoldPerKm * multiplier)
          .round(),
      warpPoints:
          (safeDistance * BalanceConfig.movementWarpPointsPerKm * multiplier)
              .round(),
      multiplier: multiplier,
      settledAt: settledAt,
      source: source,
    );
  }
}
