import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campussafe_mobile/core/sensors/shake_detector_service.dart';

void main() {
  group('ShakeDetectorService Unit Tests', () {
    late ShakeDetectorService service;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (MethodCall methodCall) async => null,
      );
      service = ShakeDetectorService(
        shakeThreshold: 24.0,
        requiredShakeCount: 3,
        shakeWindowMs: 1200,
        triggerCooldownMs: 5000,
      );
    });

    tearDown(() {
      service.dispose();
    });

    test('service initializes with default disabled state for opt-in privacy and parameters', () {
      expect(service.isEnabled, isFalse);
      expect(service.shakeThreshold, 24.0);
      expect(service.requiredShakeCount, 3);
    });

    test('setEnabled modifies enabled state properly', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await service.setEnabled(true);
      expect(service.isEnabled, isTrue);

      await service.setEnabled(false);
      expect(service.isEnabled, isFalse);
    });
  });
}
