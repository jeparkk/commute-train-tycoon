import '../data/balance_config.dart';
import '../models/device_location.dart';
import '../models/movement_checkpoint.dart';
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
      fromLatitude: null,
      fromLongitude: null,
      toLatitude: null,
      toLongitude: null,
    );
  }

  static MovementReport fromCheckpoint({
    required MovementCheckpoint checkpoint,
    required DeviceLocation currentLocation,
    required double distanceKm,
    required bool screenOnBoost,
  }) {
    return calculate(
      distanceKm: distanceKm,
      duration: currentLocation.capturedAt.difference(checkpoint.recordedAt!),
      screenOnBoost: screenOnBoost,
      source: MovementRewardSource.gps,
      settledAt: currentLocation.capturedAt,
      fromLatitude: checkpoint.latitude,
      fromLongitude: checkpoint.longitude,
      toLatitude: currentLocation.latitude,
      toLongitude: currentLocation.longitude,
    );
  }

  static MovementReport calculate({
    required double distanceKm,
    required Duration duration,
    required bool screenOnBoost,
    required MovementRewardSource source,
    required DateTime settledAt,
    required double? fromLatitude,
    required double? fromLongitude,
    required double? toLatitude,
    required double? toLongitude,
  }) {
    final safeDistance = distanceKm.clamp(0, 100).toDouble();
    final multiplier = screenOnBoost
        ? BalanceConfig.movementScreenOnMultiplier
        : 1.0;
    final rewardDistance = safeDistance >= BalanceConfig.minimumMovementRewardKm
        ? safeDistance
        : 0.0;

    return MovementReport(
      distanceKm: safeDistance,
      duration: duration,
      gold: (rewardDistance * BalanceConfig.movementGoldPerKm * multiplier)
          .round(),
      warpPoints:
          (rewardDistance * BalanceConfig.movementWarpPointsPerKm * multiplier)
              .round(),
      multiplier: multiplier,
      fromLatitude: fromLatitude,
      fromLongitude: fromLongitude,
      toLatitude: toLatitude,
      toLongitude: toLongitude,
      settledAt: settledAt,
      source: source,
    );
  }
}
