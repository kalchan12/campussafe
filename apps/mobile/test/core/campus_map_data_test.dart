import 'package:flutter_test/flutter_test.dart';
import 'package:campussafe_mobile/core/maps/campus_map_data.dart';

void main() {
  group('Campus Map Data & Zone Geometry', () {
    test('Campus center is defined in Adama coordinates', () {
      expect(kAdamaCampusCenter.latitude, closeTo(8.5565, 0.001));
      expect(kAdamaCampusCenter.longitude, closeTo(39.2910, 0.001));
    });

    test('Campus blocks are properly registered', () {
      expect(kAdamaCampusBlocks.length, greaterThanOrEqualTo(8));
      final admin = kAdamaCampusBlocks.firstWhere((b) => b.id == 'admin');
      expect(admin.name, contains('Administration'));
    });

    test('isInsideCampusZone correctly identifies points inside ASTU campus', () {
      // Administration Building (inside)
      expect(isInsideCampusZone(8.5565, 39.2910), isTrue);

      // Engineering Complex Block B (inside)
      expect(isInsideCampusZone(8.5582, 39.2895), isTrue);

      // University Stadium (inside)
      expect(isInsideCampusZone(8.5645, 39.2955), isTrue);

      // Research Complex (inside)
      expect(isInsideCampusZone(8.5625, 39.3040), isTrue);
    });

    test('isInsideCampusZone correctly rejects points outside ASTU campus', () {
      // Addis Ababa / distant coordinate
      expect(isInsideCampusZone(9.0300, 38.7400), isFalse);

      // Far south of Adama
      expect(isInsideCampusZone(8.4000, 39.2000), isFalse);

      // Far north of Adama
      expect(isInsideCampusZone(8.7000, 39.3000), isFalse);
    });

    test('MapStyleOption provides valid tile URL templates', () {
      for (final style in MapStyleOption.values) {
        expect(style.urlTemplate, startsWith('https://'));
        expect(style.label, isNotEmpty);
      }
    });
  });
}
