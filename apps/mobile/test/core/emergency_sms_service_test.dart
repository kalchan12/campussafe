import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campussafe_mobile/core/services/emergency_sms_service.dart';

void main() {
  group('EmergencySmsService Tests', () {
    late EmergencySmsService smsService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
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

    test('getAllEmergencyRecipients returns Parent and Campus Admin 0920304050', () async {
      // Mock initial SharedPreferences
      TestWidgetsFlutterBinding.ensureInitialized();
      
      await smsService.saveEmergencyContacts(
        parentPhone: '0911223344',
        parentName: 'Mom',
        campusAdminPhone: '0920304050',
      );

      final recipients = await smsService.getAllEmergencyRecipients();
      expect(recipients, contains('0911223344'));
      expect(recipients, contains('0920304050'));
      expect(recipients.length, 2);

      final parentPhone = await smsService.getParentPhone();
      expect(parentPhone, '0911223344');

      final campusPhone = await smsService.getCampusAdminPhone();
      expect(campusPhone, '0920304050');
    });

    test('defaultCampusDispatchNumber defaults to 0920304050', () {
      expect(EmergencySmsService.defaultCampusDispatchNumber, '0920304050');
    });
  });
}
