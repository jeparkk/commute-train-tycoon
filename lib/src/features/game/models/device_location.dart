class DeviceLocation {
  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
  });

  final double latitude;
  final double longitude;
  final DateTime capturedAt;
}
