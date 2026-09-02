import 'package:campussafe_mobile/features/incidents/presentation/pages/incidents_page.dart';
import 'package:campussafe_mobile/features/incidents/presentation/state/incidents_provider.dart';
import 'package:campussafe_mobile/shared/models/incident.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('IncidentsPage displays loading loader animation when incidents are fetching', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incidentsLoadingProvider.overrideWith((ref) => true),
          incidentsListProvider.overrideWith((ref) => _MockIncidentsNotifier([])),
        ],
        child: const MaterialApp(
          home: IncidentsPage(),
        ),
      ),
    );

    // Initial pump to build widgets
    await tester.pump(const Duration(milliseconds: 100));

    // Verify loading message and radar indicator are present
    expect(find.text('Fetching Campus Emergencies...'), findsOneWidget);
    expect(find.text('Connecting to real-time incident feed and dispatch channels'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.text('No Active Emergencies'), findsNothing);
  });

  testWidgets('IncidentsPage displays empty state when done loading with no incidents', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incidentsLoadingProvider.overrideWith((ref) => false),
          incidentsListProvider.overrideWith((ref) => _MockIncidentsNotifier([])),
        ],
        child: const MaterialApp(
          home: IncidentsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Fetching Campus Emergencies...'), findsNothing);
    expect(find.text('No Active Emergencies'), findsOneWidget);
    expect(find.text('Campus is currently secure. No incidents match your active filter.'), findsOneWidget);
  });
}

class _MockIncidentsNotifier extends StateNotifier<List<Incident>> implements IncidentsNotifier {
  _MockIncidentsNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
