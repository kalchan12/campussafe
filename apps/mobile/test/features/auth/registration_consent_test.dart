import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campussafe_mobile/features/auth/presentation/pages/registration_page.dart';

void main() {
  group('RegistrationPage Stepper & Consent Step Tests', () {
    testWidgets('RegistrationPage displays 5-step onboarding flow including Consent',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegistrationPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify stepper labels
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Role'), findsOneWidget);
      expect(find.text('Contacts'), findsOneWidget);
      expect(find.text('Consent'), findsOneWidget);
      expect(find.text('Campus'), findsOneWidget);

      // Initially on Account step
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('University Email'), findsOneWidget);
    });
  });
}
