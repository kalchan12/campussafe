import 'package:flutter_test/flutter_test.dart';
import 'package:campussafe_mobile/core/services/emergency_sms_service.dart';

void main() {
  group('EmergencySmsService Tests', () {
    late EmergencySmsService smsService;

    setUp(() {
      smsService = EmergencySmsService();
    });

    test('formatEmergencyMessage includes vital fields and coordinates', () {
      final msg = smsService.formatEmergencyMessage(
        emergencyType: 'medical',
        locationDescription: 'Engineering Block, Room 204',
        latitude: 8.5412,
        longitude: 39.2914,
        senderName: 'Kaleb Chanchal',
        notes: 'Student collapsed unconscious',
      );

      expect(msg, contains('CAMPUSSAFE EMERGENCY SOS'));
      expect(msg, contains('Student: Kaleb Chanchal'));
      expect(msg, contains('Type: MEDICAL'));
      expect(msg, contains('Location: Engineering Block, Room 204'));
      expect(msg, contains('GPS: 8.54120, 39.29140'));
      expect(msg, contains('https://maps.google.com/?q=8.5412,39.2914'));
      expect(msg, contains('Notes: Student collapsed unconscious'));
    });

    test('formatEmergencyMessage formats correctly without optional parameters', () {
      final msg = smsService.formatEmergencyMessage(
        emergencyType: 'security',
        locationDescription: 'ASTU Library Walkway',
      );

      expect(msg, contains('CAMPUSSAFE EMERGENCY SOS'));
      expect(msg, contains('Type: SECURITY'));
      expect(msg, contains('Location: ASTU Library Walkway'));
      expect(msg, isNot(contains('GPS:')));
      expect(msg, isNot(contains('Notes:')));
    });
  });
}
