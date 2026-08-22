import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/sos/presentation/pages/sos_page.dart';
import '../../features/incidents/presentation/pages/incidents_page.dart';
import '../../features/incidents/presentation/pages/incident_detail_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/reports/presentation/pages/submit_report_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/responder/presentation/pages/responder_home_page.dart';
import '../../features/responder/presentation/pages/available_incidents_page.dart';
import '../../features/responder/presentation/pages/incident_details_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../shared/widgets/splash_screen.dart';
import '../../shared/widgets/guest_mode_wrapper.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegistrationPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/guest',
        name: 'guestMode',
        builder: (context, state) => const GuestModeWrapper(),
      ),
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNav(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: '/incidents',
            name: 'incidents',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: IncidentsPage(),
            ),
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportsPage(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfilePage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/sos',
        name: 'sos',
        builder: (context, state) => const SOSPage(),
      ),
      GoRoute(
        path: '/incident/:id',
        name: 'incidentDetail',
        builder: (context, state) => IncidentDetailPage(
          incidentId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/reports/new',
        name: 'submitReport',
        builder: (context, state) => const SubmitReportPage(),
      ),
      GoRoute(
        path: '/responder',
        name: 'responderHome',
        builder: (context, state) => const ResponderHomePage(),
      ),
      GoRoute(
        path: '/responder/available',
        name: 'availableIncidents',
        builder: (context, state) => const AvailableIncidentsPage(),
      ),
      GoRoute(
        path: '/responder/incident/:id',
        name: 'responderIncidentDetail',
        builder: (context, state) => IncidentDetailsPage(
          incidentId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
});

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNav({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_amber_outlined),
            selectedIcon: Icon(Icons.warning_amber),
            label: 'Incidents',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/incidents')) return 1;
    if (location.startsWith('/reports')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/incidents');
      case 2:
        context.go('/reports');
      case 3:
        context.go('/profile');
    }
  }
}
