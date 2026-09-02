import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/constants.dart';
import '../errors/app_error.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class LocationService {
  Future<Result<Position>> getCurrentLocation() async {
    try {
      final permission = await _checkPermission();
      if (permission.isLeft()) {
        return Left(LocationError.permissionDenied());
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Try last known position even if service is disabled
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          return Right(lastKnown);
        }
        return Left(LocationError.serviceDisabled());
      }

      // 1. Fast check: try last known position first
      final lastKnown = await Geolocator.getLastKnownPosition();
      
      // 2. Fetch fresh position with reasonable timeout
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5),
        );
        return Right(position);
      } catch (freshError) {
        // If fresh GPS fails/times out, use last known position if available
        if (lastKnown != null) {
          return Right(lastKnown);
        }
        
        if (freshError.toString().contains('timeout')) {
          return Left(LocationError.timeout());
        }
        return Left(LocationError(
          message: 'GPS fix unavailable (${freshError.toString()})',
        ));
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        return Left(LocationError.timeout());
      }
      return Left(LocationError(
        message: 'Failed to get location: ${e.toString()}',
      ));
    }
  }

  Future<Result<void>> _checkPermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Left(LocationError.permissionDenied());
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Left(LocationError.permissionDenied());
    }

    return const Right(null);
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}
