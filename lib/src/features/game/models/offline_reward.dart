class OfflineReward {
  const OfflineReward({
    required this.gold,
    required this.duration,
    required this.maxDuration,
    required this.efficiency,
  });

  final int gold;
  final Duration duration;
  final Duration maxDuration;
  final double efficiency;

  bool get hasReward => gold > 0;
  bool get reachedCap => duration >= maxDuration;
}
