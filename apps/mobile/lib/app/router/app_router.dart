import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/state/auth_notifier.dart';
import '../../features/auth/presentation/state/auth_state.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/sos/presentation/pages/sos_page.dart';
import '../../features/sos/presentation/pages/active_emergency_page.dart';
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
import '../../shared/widgets/navigation.dart';

/// Routes accessible without authentication
const _publicRoutes = ['/', '/login', '/register', '/forgot-password', '/guest', '/sos'];

/// A ChangeNotifier that triggers GoRouter's refreshListenable when auth state changes
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: (context, routerState) {
      final authState = ref.read(authNotifierProvider);
      final path = routerState.uri.path;
      final isPublic = _publicRoutes.any((r) => path.startsWith(r));
      final isAuthenticated = authState.isAuthenticated;
      final isGuest = authState.isGuest;

      // Splash always loads
      if (path == '/') return null;

      // Not authenticated and not guest trying to access a protected route
      if (!isAuthenticated && !isGuest && !isPublic) return '/login';

      // Already authenticated trying to reach login/register — send home
      if (isAuthenticated && (path == '/login' || path == '/register')) {
        return '/home';
      }

      return null;
    },
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
        builder: (context, state, child) {
          int currentIndex = 0;
          final location = state.uri.toString();
          if (location.startsWith('/home')) currentIndex = 0;
          else if (location.startsWith('/incidents')) currentIndex = 1;
          else if (location.startsWith('/reports')) currentIndex = 2;
          else if (location.startsWith('/profile')) currentIndex = 3;

          return ScaffoldWithNav(
            currentIndex: currentIndex,
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/home');
                  break;
                case 1:
                  context.go('/incidents');
                  break;
                case 2:
                  context.go('/reports');
                  break;
                case 3:
                  context.go('/profile');
                  break;
              }
            },
            destinations: const [
              BottomNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
              ),
              BottomNavItem(
                icon: Icons.warning_amber_outlined,
                selectedIcon: Icons.warning_amber,
                label: 'Incidents',
              ),
              BottomNavItem(
                icon: Icons.notifications_outlined,
                selectedIcon: Icons.notifications,
                label: 'Alerts',
              ),
              BottomNavItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'Profile',
              ),
            ],
            child: child,
          );
        },
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
      GoRoute(
        path: '/emergency/active/:id',
        name: 'activeEmergency',
        builder: (context, state) => IncidentDetailPage(
          incidentId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});
