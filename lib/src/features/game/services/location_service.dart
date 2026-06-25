import 'package:geolocator/geolocator.dart';

import '../models/device_location.dart';

abstract class LocationService {
  Future<DeviceLocation> getCurrentLocation();

  double distanceBetweenMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  });
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<DeviceLocation> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException('기기 위치 서비스가 꺼져 있습니다');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationServiceException('위치 권한이 필요합니다');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException('설정에서 위치 권한을 허용해 주세요');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 12),
      ),
    );

    return DeviceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      capturedAt: DateTime.now(),
    );
  }

  @override
  double distanceBetweenMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}

class LocationServiceException implements Exception {
  const LocationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
