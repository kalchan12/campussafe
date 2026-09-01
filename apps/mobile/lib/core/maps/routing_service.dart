import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

final routingServiceProvider = Provider<RoutingService>((ref) {
  return RoutingService();
});

/// Multi-modal travel time and distance estimates
class TravelModeEstimates {
  final int walkingMinutes;
  final String walkingText;
  final int bicyclingMinutes;
  final String bicyclingText;
  final int drivingMinutes;
  final String drivingText;
  final int distanceMeters;
  final String formattedDistance;

  const TravelModeEstimates({
    required this.walkingMinutes,
    required this.walkingText,
    required this.bicyclingMinutes,
    required this.bicyclingText,
    required this.drivingMinutes,
    required this.drivingText,
    required this.distanceMeters,
    required this.formattedDistance,
  });
}

/// Calculated route geometry and metadata
class RouteResult {
  final List<LatLng> coordinates;
  final int distanceMeters;
  final int durationSeconds;
  final TravelModeEstimates estimates;
  final bool isRealRoadRoute;

  const RouteResult({
    required this.coordinates,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.estimates,
    required this.isRealRoadRoute,
  });
}

/// Formats minutes into human-readable duration (e.g., '4 min' or '1h 12m')
String formatMinutes(int minutes) {
  if (minutes < 60) {
    return '$minutes min';
  }
  final h = minutes ~/ 60;
  final rem = minutes % 60;
  return '${h}h ${rem}m';
}

/// Formats distance in meters into human-readable format (e.g., '140 m' or '1.4 km')
String formatDistanceMeters(int meters) {
  if (meters < 1000) {
    return '$meters m';
  }
  return '${(meters / 1000.0).toStringAsFixed(1)} km';
}

/// Calculates multi-modal transit estimates (Walking ~80m/min, Cycling ~250m/min, Driving ~500m/min)
TravelModeEstimates calculateTravelEstimates(int distanceMeters) {
  final walkMins = math.max(1, (distanceMeters / 80.0).ceil());
  final bikeMins = math.max(1, (distanceMeters / 250.0).ceil());
  final carMins = math.max(1, (distanceMeters / 500.0).ceil());

  return TravelModeEstimates(
    walkingMinutes: walkMins,
    walkingText: formatMinutes(walkMins),
    bicyclingMinutes: bikeMins,
    bicyclingText: formatMinutes(bikeMins),
    drivingMinutes: carMins,
    drivingText: formatMinutes(carMins),
    distanceMeters: distanceMeters,
    formattedDistance: formatDistanceMeters(distanceMeters),
  );
}

/// Computes straight-line Haversine distance in meters between two LatLng points
int calculateHaversineDistance(LatLng start, LatLng end) {
  const distance = Distance();
  return distance.as(LengthUnit.Meter, start, end).toInt();
}

class RoutingService {
  final Dio _dio;

  RoutingService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(milliseconds: 3000),
                receiveTimeout: const Duration(milliseconds: 3000),
                sendTimeout: const Duration(milliseconds: 3000),
              ),
            );

  /// Fetches optimal pedestrian route from public OpenStreetMap OSRM engine
  /// with automatic offline geodesic fallback.
  Future<RouteResult> getBestRoute(LatLng start, LatLng end) async {
    final straightMeters = calculateHaversineDistance(start, end);

    try {
      final url =
          'https://router.project-osrm.org/route/v1/foot/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0] as Map<String, dynamic>;
          final geometry = route['geometry'] as Map<String, dynamic>;
          final rawCoords = geometry['coordinates'] as List;

          final coords = rawCoords.map<LatLng>((c) {
            final pair = c as List;
            return LatLng(
              (pair[1] as num).toDouble(),
              (pair[0] as num).toDouble(),
            );
          }).toList();

          final actualMeters = (route['distance'] as num).round();
          final durationSecs = (route['duration'] as num).round();

          return RouteResult(
            coordinates: coords,
            distanceMeters: actualMeters,
            durationSeconds: durationSecs,
            estimates: calculateTravelEstimates(actualMeters),
            isRealRoadRoute: true,
          );
        }
      }
    } catch (_) {
      // Fallback seamlessly to geodesic path on network failure/timeout
    }

    // Geodesic straight-line fallback with 1.2x road curvature estimate
    final roadAdjustedMeters = (straightMeters * 1.2).round();
    return RouteResult(
      coordinates: [start, end],
      distanceMeters: straightMeters,
      durationSeconds: (roadAdjustedMeters / 1.33).round(),
      estimates: calculateTravelEstimates(roadAdjustedMeters),
      isRealRoadRoute: false,
    );
  }
}
