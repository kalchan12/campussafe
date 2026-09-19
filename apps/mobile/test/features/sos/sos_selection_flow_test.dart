import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campussafe_mobile/features/sos/presentation/pages/sos_page.dart';
import 'package:campussafe_mobile/features/sos/presentation/state/sos_notifier.dart';
import 'package:campussafe_mobile/features/sos/presentation/state/sos_state.dart';

void main() {
  group('SOS Direct Selection Flow Tests', () {
    testWidgets('SOSPage in selectingType status displays Medical and Security, but excludes Fire and Accident',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sosNotifierProvider.overrideWith(
              (ref) => _FakeSosNotifier(const SosState(status: SosStatus.selectingType)),
            ),
          ],
          child: const MaterialApp(
            home: SOSPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show the question header
      expect(find.text('What type of emergency?'), findsOneWidget);

      // Should show Medical and Security categories
      expect(find.text('Medical'), findsOneWidget);
      expect(find.text('Ambulance & First Aid'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Campus Police & Patrol'), findsOneWidget);

      // MUST NOT show Fire Hazard or Accident categories (sensor triggered only)
      expect(find.text('Fire'), findsNothing);
      expect(find.text('Smoke & Fire Alarm'), findsNothing);
      expect(find.text('Accident'), findsNothing);
      expect(find.text('Vehicle or Physical Collision'), findsNothing);

      // Should NOT show confirmation dialog/screen
      expect(find.text('Confirm Emergency Alert'), findsNothing);
    });

    testWidgets('SOSPage in confirming status directly routes to type selection view',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sosNotifierProvider.overrideWith(
              (ref) => _FakeSosNotifier(const SosState(status: SosStatus.confirming)),
            ),
          ],
          child: const MaterialApp(
            home: SOSPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Bypasses confirmation view directly
      expect(find.text('Confirm Emergency Alert'), findsNothing);
      expect(find.text('What type of emergency?'), findsOneWidget);
      expect(find.text('Medical'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
    });
  });
}

class _FakeSosNotifier extends StateNotifier<SosState> implements SosNotifier {
  _FakeSosNotifier(super.state);

  @override
  void startTypeSelection() {
    state = state.copyWith(status: SosStatus.selectingType);
  }

  @override
  void startConfirmation() {
    state = state.copyWith(status: SosStatus.selectingType);
  }

  @override
  void reset() {
    state = const SosState();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
