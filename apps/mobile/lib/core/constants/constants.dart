class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'CampusSafe';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String guestModeKey = 'guest_mode';

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration locationTimeout = Duration(seconds: 10);
  static const Duration splashDuration = Duration(seconds: 2);

  // SOS
  static const int sosConfirmationDuration = 5;
  static const double minimumLocationAccuracy = 100.0;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
