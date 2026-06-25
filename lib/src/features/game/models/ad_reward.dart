class AdReward {
  const AdReward({
    required this.placement,
    required this.gold,
    required this.message,
  });

  final AdPlacement placement;
  final int gold;
  final String message;
}

enum AdPlacement {
  offlineDouble(label: '오프라인 2배 정산'),
  supportGrant(label: '긴급 지원금');

  const AdPlacement({required this.label});

  final String label;
}
