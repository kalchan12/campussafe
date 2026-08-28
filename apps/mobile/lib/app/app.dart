import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../core/network/sync_service.dart';
import '../core/location/responder_location_tracker.dart';

class CampusSafeApp extends ConsumerWidget {
  const CampusSafeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize background services
    ref.watch(syncServiceProvider);
    ref.watch(responderLocationTrackerProvider);

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'CampusSafe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
