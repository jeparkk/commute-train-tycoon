class MovementReport {
  const MovementReport({
    required this.distanceKm,
    required this.duration,
    required this.gold,
    required this.warpPoints,
    required this.multiplier,
    required this.settledAt,
    required this.source,
  });

  const MovementReport.empty()
    : distanceKm = 0,
      duration = Duration.zero,
      gold = 0,
      warpPoints = 0,
      multiplier = 1,
      settledAt = null,
      source = MovementRewardSource.none;

  final double distanceKm;
  final Duration duration;
  final int gold;
  final int warpPoints;
  final double multiplier;
  final DateTime? settledAt;
  final MovementRewardSource source;

  bool get hasReward => gold > 0 || warpPoints > 0;
}

enum MovementRewardSource {
  none(label: '기록 없음'),
  demo(label: '테스트 이동'),
  gps(label: 'GPS 이동');

  const MovementRewardSource({required this.label});

  final String label;
}
