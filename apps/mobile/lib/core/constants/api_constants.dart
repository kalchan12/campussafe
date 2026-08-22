class ApiConstants {
  ApiConstants._();

  // Base URLs
  static const String apiVersion = '/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';

  // Users
  static const String users = '/users';
  static String user(String id) => '/users/$id';
  static const String userProfile = '/users/profile';

  // Incidents
  static const String incidents = '/incidents';
  static String incident(String id) => '/incidents/$id';
  static const String sosIncidents = '/incidents/sos';
  static String incidentStatus(String id) => '/incidents/$id/status';
  static String incidentAssign(String id) => '/incidents/$id/assign';

  // Reports
  static const String reports = '/reports';
  static String report(String id) => '/reports/$id';

  // Devices
  static const String devices = '/devices';
  static String device(String id) => '/devices/$id';
  static String deviceEvent(String id) => '/devices/$id/events';

  // Responders
  static const String responders = '/responders';
  static String responder(String id) => '/responders/$id';
  static const String responderAvailability = '/responders/availability';

  // Notifications
  static const String notifications = '/notifications';
  static const String markRead = '/notifications/read';

  // Location
  static const String campusLocations = '/locations';
}
