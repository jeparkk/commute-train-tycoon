class MovementCheckpoint {
  const MovementCheckpoint({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
  });

  const MovementCheckpoint.empty()
    : latitude = null,
      longitude = null,
      recordedAt = null;

  final double? latitude;
  final double? longitude;
  final DateTime? recordedAt;

  bool get hasLocation =>
      latitude != null && longitude != null && recordedAt != null;
}
