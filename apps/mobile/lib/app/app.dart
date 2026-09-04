import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../core/network/sync_service.dart';
import '../core/location/responder_location_tracker.dart';
import '../features/incidents/presentation/state/incidents_provider.dart';
import '../features/auth/presentation/state/auth_notifier.dart';

class CampusSafeApp extends ConsumerStatefulWidget {
  const CampusSafeApp({super.key});

  @override
  ConsumerState<CampusSafeApp> createState() => _CampusSafeAppState();
}

class _CampusSafeAppState extends ConsumerState<CampusSafeApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // No action needed for now — hooks are ready for future use
        break;
    }
  }

  /// Called when the app returns to the foreground.
  ///
  /// Reconnects Supabase Realtime streams (which die when the OS drops
  /// websockets in background), syncs any queued incidents, and refreshes
  /// the active incidents list to restore stale in-memory state.
  void _onAppResumed() {
    final authState = ref.read(authNotifierProvider);
    if (!authState.isAuthenticated) return;

    // 1. Reload active incidents from backend & reconnect realtime
    ref.read(incidentsListProvider.notifier).reconnect();

    // 2. Sync any incidents queued while offline/background
    ref.read(syncServiceProvider).syncPendingIncidents();
  }

  @override
  Widget build(BuildContext context) {
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
