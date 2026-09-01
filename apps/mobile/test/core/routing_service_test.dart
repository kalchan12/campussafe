import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:campussafe_mobile/core/maps/routing_service.dart';

void main() {
  group('Routing Service & Multi-modal Estimates', () {
    test('calculateTravelEstimates computes realistic walk, bike, drive times', () {
      // 800 meters distance
      final estimates = calculateTravelEstimates(800);

      // Walk at ~80m/min -> 10 mins
      expect(estimates.walkingMinutes, equals(10));
      expect(estimates.walkingText, equals('10 min'));

      // Bike at ~250m/min -> 4 mins (ceil of 3.2)
      expect(estimates.bicyclingMinutes, equals(4));
      expect(estimates.bicyclingText, equals('4 min'));

      // Drive at ~500m/min -> 2 mins (ceil of 1.6)
      expect(estimates.drivingMinutes, equals(2));
      expect(estimates.drivingText, equals('2 min'));

      expect(estimates.formattedDistance, equals('800 m'));
    });

    test('formatDistanceMeters formats meters and kilometers properly', () {
      expect(formatDistanceMeters(450), equals('450 m'));
      expect(formatDistanceMeters(1500), equals('1.5 km'));
      expect(formatDistanceMeters(2340), equals('2.3 km'));
    });

    test('formatMinutes handles under 1h and over 1h', () {
      expect(formatMinutes(15), equals('15 min'));
      expect(formatMinutes(75), equals('1h 15m'));
      expect(formatMinutes(120), equals('2h 0m'));
    });

    test('RoutingService geodesic fallback works when network fails or mocks offline', () async {
      final service = RoutingService();
      const start = LatLng(8.5565, 39.2910); // EOC
      const end = LatLng(8.5582, 39.2895); // Engineering

      final route = await service.getBestRoute(start, end);

      expect(route.coordinates.length, greaterThanOrEqualTo(2));
      expect(route.distanceMeters, greaterThan(0));
      expect(route.estimates.walkingMinutes, greaterThan(0));
    });
  });
}
