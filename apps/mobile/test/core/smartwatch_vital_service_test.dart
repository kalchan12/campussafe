import 'package:flutter_test/flutter_test.dart';
import 'package:campussafe_mobile/core/sensors/smartwatch_vital_service.dart';
import 'package:campussafe_mobile/shared/models/smartwatch_vitals.dart';

void main() {
  group('SmartwatchVitalService Unit Tests', () {
    late SmartwatchVitalService service;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      service = SmartwatchVitalService();
    });

    tearDown(() {
      service.dispose();
    });

    test('initializes with monitoring enabled and disconnected vitals', () {
      expect(service.isMonitoringEnabled, isTrue);
      expect(service.isAutoSosEnabled, isTrue);
      expect(service.currentVitals.isConnected, isFalse);
      expect(service.currentVitals.heartRateBpm, 0);
      expect(service.currentVitals.isCriticalEmergency, isFalse);
    });

    test('connectSmartwatch transitions to connected state with healthy vitals', () async {
      await service.connectSmartwatch(model: 'Apple Watch Series 9');
      expect(service.currentVitals.isConnected, isTrue);
      expect(service.currentVitals.deviceModel, 'Apple Watch Series 9');
      expect(service.currentVitals.heartRateBpm, 74);
    });

    test('disconnectSmartwatch zeros organ readings and stops active telemetry', () async {
      await service.connectSmartwatch();
      expect(service.currentVitals.isConnected, isTrue);

      await service.disconnectSmartwatch();
      expect(service.currentVitals.isConnected, isFalse);
      expect(service.currentVitals.heartRateBpm, 0);
      expect(service.currentVitals.bloodOxygenSpO2, 0.0);
      expect(service.currentVitals.bodyTemperature, 0.0);
      expect(service.currentVitals.isCriticalEmergency, isFalse);
    });

    test('setting monitoring enabled modifies state correctly', () async {
      await service.setMonitoringEnabled(false);
      expect(service.isMonitoringEnabled, isFalse);

      await service.setMonitoringEnabled(true);
      expect(service.isMonitoringEnabled, isTrue);
    });

    test('setting auto SOS enabled modifies state correctly', () async {
      await service.setAutoSosEnabled(false);
      expect(service.isAutoSosEnabled, isFalse);

      await service.setAutoSosEnabled(true);
      expect(service.isAutoSosEnabled, isTrue);
    });

    test('tachycardia simulation emits alert tick and triggers critical status', () async {
      final alertEvents = <SmartwatchAlertEvent>[];
      final subscription = service.alertStream.listen(alertEvents.add);

      service.simulateTachycardia();

      await Future.delayed(const Duration(milliseconds: 50));
      expect(service.currentVitals.isCriticalEmergency, isTrue);
      expect(service.currentVitals.heartRateBpm, 168);
      expect(alertEvents.isNotEmpty, isTrue);
      expect(alertEvents.first.type, AlertEventType.countdownTick);
      expect(alertEvents.first.reason, contains('Tachycardia'));

      await subscription.cancel();
    });

    test('dismissEmergencyAlert resets vitals to healthy and sends dismissed event', () async {
      final alertEvents = <SmartwatchAlertEvent>[];
      final subscription = service.alertStream.listen(alertEvents.add);

      service.simulateHypoxia();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(service.currentVitals.isCriticalEmergency, isTrue);

      service.dismissEmergencyAlert();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(service.currentVitals.isCriticalEmergency, isFalse);
      expect(alertEvents.any((e) => e.type == AlertEventType.dismissed), isTrue);

      await subscription.cancel();
    });

    test('triggerImmediateEmergencyDispatch invokes onEmergencyTriggered callback', () async {
      SmartwatchVitals? triggeredVitals;
      String? triggeredReason;

      service.onEmergencyTriggered = (vitals, reason) {
        triggeredVitals = vitals;
        triggeredReason = reason;
      };

      service.simulateFallAndCollapse();
      await Future.delayed(const Duration(milliseconds: 50));

      service.triggerImmediateEmergencyDispatch();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(triggeredVitals, isNotNull);
      expect(triggeredVitals!.fallDetected, isTrue);
      expect(triggeredReason, contains('Hard Fall'));
    });
  });
}
