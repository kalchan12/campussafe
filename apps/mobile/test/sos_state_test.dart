import 'package:flutter_test/flutter_test.dart';
import 'package:campussafe_mobile/features/sos/presentation/state/sos_state.dart';

void main() {
  group('SOS State Tests', () {
    test('initial state should be ready', () {
      const state = SosState();
      expect(state.status, SosStatus.ready);
      expect(state.emergencyType, isNull);
      expect(state.latitude, isNull);
      expect(state.longitude, isNull);
      expect(state.error, isNull);
      expect(state.isLocationLoading, isFalse);
    });

    test('should copy state with new values', () {
      const state = SosState();
      final newState = state.copyWith(
        status: SosStatus.confirming,
        emergencyType: 'medical',
      );

      expect(newState.status, SosStatus.confirming);
      expect(newState.emergencyType, 'medical');
      expect(newState.latitude, isNull);
    });

    test('should copy state and clear error', () {
      final state = SosState(error: 'Test error');
      final newState = state.copyWith(status: SosStatus.ready);

      expect(newState.error, isNull);
    });

    test('should maintain values when copying without changes', () {
      const state = SosState(
        status: SosStatus.selectingType,
        emergencyType: 'security',
        latitude: 1.0,
        longitude: 2.0,
      );

      final newState = state.copyWith();

      expect(newState.status, SosStatus.selectingType);
      expect(newState.emergencyType, 'security');
      expect(newState.latitude, 1.0);
      expect(newState.longitude, 2.0);
    });

    test('SOS status should have correct values', () {
      expect(SosStatus.ready.index, 0);
      expect(SosStatus.confirming.index, 1);
      expect(SosStatus.selectingType.index, 2);
      expect(SosStatus.confirmingLocation.index, 3);
      expect(SosStatus.sending.index, 4);
      expect(SosStatus.sent.index, 5);
      expect(SosStatus.received.index, 6);
      expect(SosStatus.failed.index, 7);
    });
  });
}
