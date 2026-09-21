import 'package:flutter_test/flutter_test.dart';
import 'package:campussafe_mobile/shared/models/smartwatch_vitals.dart';

void main() {
  group('SmartwatchVitals Model & Clinical Thresholds', () {
    test('healthy baseline vitals do not trigger critical emergency', () {
      final vitals = SmartwatchVitals.healthy();
      expect(vitals.heartRateBpm, 74);
      expect(vitals.bloodOxygenSpO2, 98.0);
      expect(vitals.bodyTemperature, 36.6);
      expect(vitals.fallDetected, isFalse);
      expect(vitals.isImmobile, isFalse);
      expect(vitals.cardiacStatus, CardiacStatus.normal);
      expect(vitals.respiratoryStatus, RespiratoryStatus.normal);
      expect(vitals.isConnected, isTrue);
      expect(vitals.isCriticalEmergency, isFalse);
      expect(vitals.criticalReasons, isEmpty);
    });

    test('disconnected smartwatch zeros organ readings and suppresses alarms', () {
      final vitals = SmartwatchVitals.disconnected();
      expect(vitals.heartRateBpm, 0);
      expect(vitals.bloodOxygenSpO2, 0.0);
      expect(vitals.bodyTemperature, 0.0);
      expect(vitals.hrvMs, 0.0);
      expect(vitals.skinConductanceUs, 0.0);
      expect(vitals.fallDetected, isFalse);
      expect(vitals.isImmobile, isFalse);
      expect(vitals.isConnected, isFalse);
      expect(vitals.isCriticalEmergency, isFalse);
      expect(vitals.criticalReasons, isEmpty);
      expect(
        vitals.toClinicalSummary(),
        contains('No Smartwatch Connected (Vitals Unavailable - Sensor Offline)'),
      );
    });

    test('detects critical tachycardia when heart rate exceeds 150 BPM', () {
      final vitals = SmartwatchVitals(
        heartRateBpm: 168,
        bloodOxygenSpO2: 97.0,
        bodyTemperature: 36.8,
        cardiacStatus: CardiacStatus.tachycardia,
        timestamp: DateTime.now(),
      );

      expect(vitals.isCriticalEmergency, isTrue);
      expect(vitals.criticalReasons, contains('Critical Tachycardia (168 BPM > 150)'));
    });

    test('detects severe bradycardia when heart rate falls below 40 BPM', () {
      final vitals = SmartwatchVitals(
        heartRateBpm: 36,
        bloodOxygenSpO2: 95.0,
        bodyTemperature: 36.5,
        cardiacStatus: CardiacStatus.bradycardia,
        timestamp: DateTime.now(),
      );

      expect(vitals.isCriticalEmergency, isTrue);
      expect(vitals.criticalReasons, contains('Severe Bradycardia (36 BPM < 40)'));
    });

    test('detects critical hypoxia when SpO2 drops below 88%', () {
      final vitals = SmartwatchVitals(
        heartRateBpm: 110,
        bloodOxygenSpO2: 84.0,
        bodyTemperature: 36.7,
        respiratoryStatus: RespiratoryStatus.criticalHypoxia,
        timestamp: DateTime.now(),
      );

      expect(vitals.isCriticalEmergency, isTrue);
      expect(vitals.criticalReasons.any((r) => r.contains('Critical Hypoxia')), isTrue);
    });

    test('detects severe hypothermia (<35°C) and hyperthermia (>39.5°C)', () {
      final coldVitals = SmartwatchVitals(
        heartRateBpm: 55,
        bloodOxygenSpO2: 96.0,
        bodyTemperature: 34.2,
        temperatureStatus: TemperatureStatus.hypothermia,
        timestamp: DateTime.now(),
      );
      expect(coldVitals.isCriticalEmergency, isTrue);
      expect(coldVitals.criticalReasons.any((r) => r.contains('Hypothermia')), isTrue);

      final feverVitals = SmartwatchVitals(
        heartRateBpm: 130,
        bloodOxygenSpO2: 95.0,
        bodyTemperature: 40.2,
        temperatureStatus: TemperatureStatus.hyperthermia,
        timestamp: DateTime.now(),
      );
      expect(feverVitals.isCriticalEmergency, isTrue);
      expect(feverVitals.criticalReasons.any((r) => r.contains('Heatstroke')), isTrue);
    });

    test('detects hard fall accompanied by immobility', () {
      final vitals = SmartwatchVitals(
        heartRateBpm: 135,
        bloodOxygenSpO2: 96.0,
        bodyTemperature: 36.8,
        fallDetected: true,
        isImmobile: true,
        timestamp: DateTime.now(),
      );

      expect(vitals.isCriticalEmergency, isTrue);
      expect(vitals.criticalReasons.any((r) => r.contains('Hard Fall')), isTrue);
    });

    test('detects cardiac arrest / loss of pulse', () {
      final vitals = SmartwatchVitals(
        heartRateBpm: 0,
        bloodOxygenSpO2: 75.0,
        bodyTemperature: 35.5,
        cardiacStatus: CardiacStatus.cardiacArrest,
        timestamp: DateTime.now(),
      );

      expect(vitals.isCriticalEmergency, isTrue);
      expect(vitals.criticalReasons.any((r) => r.contains('Cardiac Arrest')), isTrue);
    });

    test('serializes to and from JSON correctly', () {
      final original = SmartwatchVitals(
        heartRateBpm: 82,
        bloodOxygenSpO2: 98.4,
        bodyTemperature: 36.7,
        hrvMs: 48.0,
        skinConductanceUs: 3.1,
        fallDetected: false,
        isImmobile: false,
        cardiacStatus: CardiacStatus.normal,
        respiratoryStatus: RespiratoryStatus.normal,
        temperatureStatus: TemperatureStatus.normal,
        deviceModel: 'Apple Watch Ultra',
        batteryLevel: 88,
        isConnected: true,
        timestamp: DateTime.parse('2026-09-21T10:00:00.000Z'),
      );

      final json = original.toJson();
      final reconstructed = SmartwatchVitals.fromJson(json);

      expect(reconstructed.heartRateBpm, original.heartRateBpm);
      expect(reconstructed.bloodOxygenSpO2, original.bloodOxygenSpO2);
      expect(reconstructed.bodyTemperature, original.bodyTemperature);
      expect(reconstructed.deviceModel, original.deviceModel);
      expect(reconstructed.cardiacStatus, original.cardiacStatus);
    });

    test('formats clinical summary string properly for dispatch', () {
      final vitals = SmartwatchVitals(
        heartRateBpm: 165,
        bloodOxygenSpO2: 86.0,
        bodyTemperature: 37.0,
        cardiacStatus: CardiacStatus.tachycardia,
        respiratoryStatus: RespiratoryStatus.criticalHypoxia,
        timestamp: DateTime.now(),
      );

      final summary = vitals.toClinicalSummary();
      expect(summary, contains('HR: 165 BPM'));
      expect(summary, contains('SpO2: 86.0%'));
      expect(summary, contains('Critical Tachycardia'));
    });
  });
}
