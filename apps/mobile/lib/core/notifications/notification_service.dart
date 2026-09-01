import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_error.dart';
import '../services/notification_token_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final tokenService = ref.watch(notificationTokenServiceProvider);
  return NotificationService(tokenService);
});

/// Android notification channel used for high-priority emergency alerts.
const _androidChannel = AndroidNotificationChannel(
  'campussafe_alerts',
  'CampusSafe Alerts',
  description: 'Emergency and safety notifications',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

class NotificationService {
  FirebaseMessaging? get _messaging {
    try {
      return FirebaseMessaging.instance;
    } catch (_) {
      return null;
    }
  }

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final NotificationTokenService _tokenService;

  /// Holds the current FCM token so we can deactivate it on sign-out.
  String? _currentToken;

  NotificationService(this._tokenService);

  // ---------- Initialization ----------

  Future<Result<void>> initialize({String? userId}) async {
    try {
      // Request permissions
      final settings = await _messaging?.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: true,
      );

      if (settings?.authorizationStatus == AuthorizationStatus.denied) {
        return const Left(
          AuthError(message: 'Notification permission denied'),
        );
      }

      // Configure local notifications (for foreground display)
      await _initLocalNotifications();

      // Register FCM token
      await _refreshToken(userId);

      // Listen for token refresh
      _messaging?.onTokenRefresh.listen((token) => _refreshToken(userId, token: token));

      // Handle foreground messages
      try {
        FirebaseMessaging.onMessage.listen(_handleForeground);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      } catch (_) {}

      // Handle notification taps when app was terminated
      final initialMessage = await _messaging?.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      return const Right(null);
    } catch (e) {
      return Left(AuthError(
        message: 'Failed to initialize notifications: ${e.toString()}',
      ));
    }
  }

  // ---------- Token management ----------

  Future<void> _refreshToken(String? userId, {String? token}) async {
    try {
      final fcmToken = token ?? await _messaging?.getToken();
      if (fcmToken == null) return;
      _currentToken = fcmToken;
      if (userId != null) {
        final platform = Platform.isIOS ? 'ios' : 'android';
        await _tokenService.registerToken(
          userId: userId,
          token: fcmToken,
          platform: platform,
        );
      }
    } catch (_) {
      // Non-fatal — the app continues to work without push
    }
  }

  /// Call this when a user signs in to associate the token with their account.
  Future<void> associateTokenWithUser(String userId) async {
    if (_currentToken == null) return;
    final platform = Platform.isIOS ? 'ios' : 'android';
    await _tokenService.registerToken(
      userId: userId,
      token: _currentToken!,
      platform: platform,
    );
  }

  /// Call this on sign-out so the user no longer receives notifications.
  Future<void> disassociateToken(String userId) async {
    if (_currentToken == null) return;
    await _tokenService.deactivateTokens(
      userId: userId,
      token: _currentToken!,
    );
    _currentToken = null;
  }

  // ---------- Local notification display ----------

  Future<void> _initLocalNotifications() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
    // Create Android notification channel
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);
  }

  void _handleForeground(RemoteMessage message) {
    // When the app is in the foreground, FCM does NOT show a system
    // notification automatically. Show one via flutter_local_notifications.
    final notification = message.notification;
    if (notification == null) return;
    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['incident_id'],
    );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    _navigateToIncident(response.payload);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final incidentId = message.data['incident_id'];
    _navigateToIncident(incidentId);
  }

  void _navigateToIncident(String? incidentId) {
    if (incidentId == null || incidentId.isEmpty) return;
    // Navigate to the incident detail page.
    // The router context is not directly available here — use a global
    // navigator key or a Riverpod state to trigger navigation.
    // For now we capture the intent and defer to the router.
    _pendingNavigationIncidentId = incidentId;
  }

  /// Consumed by the app router on startup/resume to deep-link into an incident.
  String? _pendingNavigationIncidentId;
  String? consumePendingNavigation() {
    final id = _pendingNavigationIncidentId;
    _pendingNavigationIncidentId = null;
    return id;
  }

  // ---------- Topics ----------

  Future<void> subscribeToTopic(String topic) async {
    await _messaging?.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging?.unsubscribeFromTopic(topic);
  }

  /// Returns the current FCM token (useful for debugging).
  Future<String?> getToken() async => _messaging?.getToken();
}
