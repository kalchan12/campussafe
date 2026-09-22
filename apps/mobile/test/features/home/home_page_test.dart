import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campussafe_mobile/features/home/presentation/pages/home_page.dart';

void main() {
  group('HomePage Widget Tests', () {
    testWidgets('HomePage renders greeting, SOS button, vital card, and emergency types',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify HomePage renders essential components
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.textContaining('Hello,'), findsOneWidget);
      expect(find.text('ASTU Campus: Secure & Active'), findsOneWidget);
      expect(find.text('Smartwatch Vital Sentinel'), findsOneWidget);
      expect(find.text('Quick Emergency Types'), findsOneWidget);
      expect(find.text('Medical'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Campus Safety Network'), findsOneWidget);
    });

    testWidgets('HomePage in guest mode displays Login for Full Access banner',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(isGuest: true),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Login for Full Access'), findsOneWidget);
      expect(find.text('Login to send SOS alerts and track incidents'), findsOneWidget);
    });
  });
}
