import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campussafe_mobile/features/home/presentation/pages/home_page.dart';
import 'package:campussafe_mobile/core/sensors/smartwatch_vital_service.dart';

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

    testWidgets('HomePage on 720x1344 device with vital monitoring enabled renders without layout error',
        (tester) async {
      tester.view.physicalSize = const Size(720, 1344);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            smartwatchVitalsNotifierProvider.overrideWith(
              (ref) => SmartwatchVitalsNotifier(ref.watch(smartwatchVitalServiceProvider))
                ..setMonitoringEnabled(true),
            ),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('HomePage on compact 320px width device with 1.3x font scaling renders without layout error',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            smartwatchVitalsNotifierProvider.overrideWith(
              (ref) => SmartwatchVitalsNotifier(ref.watch(smartwatchVitalServiceProvider))
                ..setMonitoringEnabled(true),
            ),
          ],
          child: const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
              child: HomePage(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
