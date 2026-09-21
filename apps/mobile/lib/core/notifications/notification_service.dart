import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
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

  void Function(String incidentId)? _onNotificationTapCallback;

  NotificationService(this._tokenService);

  // ---------- Initialization ----------

  Future<Result<void>> initialize({
    String? userId,
    void Function(String incidentId)? onNotificationTap,
  }) async {
    _onNotificationTapCallback = onNotificationTap;
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

      // Resolve current user ID if not explicitly provided
      final effectiveUserId = userId ??
          (Env.isConfigured ? Env.supabase.auth.currentUser?.id : null);

      // Register FCM token
      await _refreshToken(effectiveUserId);

      // Listen for token refresh
      _messaging?.onTokenRefresh.listen((token) => _refreshToken(effectiveUserId, token: token));

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
    try {
      final token = _currentToken ?? await _messaging?.getToken();
      if (token == null) return;
      _currentToken = token;
      final platform = Platform.isIOS ? 'ios' : 'android';
      await _tokenService.registerToken(
        userId: userId,
        token: token,
        platform: platform,
      );
    } catch (_) {
      // Non-fatal
    }
  }

  /// Call this on sign-out so the user no longer receives notifications.
  Future<void> disassociateToken(String userId) async {
    final token = _currentToken ?? await _messaging?.getToken();
    if (token == null) return;
    await _tokenService.deactivateTokens(
      userId: userId,
      token: token,
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
    _pendingNavigationIncidentId = incidentId;
    _onNotificationTapCallback?.call(incidentId);
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
