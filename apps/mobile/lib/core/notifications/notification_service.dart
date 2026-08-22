import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_error.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<Result<void>> initialize() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        return const Left(AuthError(
          message: 'Notification permission denied',
        ));
      }

      final token = await _messaging.getToken();
      if (token != null) {
        await _sendTokenToServer(token);
      }

      _messaging.onTokenRefresh.listen(_sendTokenToServer);

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      return const Right(null);
    } catch (e) {
      return Left(AuthError(
        message: 'Failed to initialize notifications: ${e.toString()}',
      ));
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    // TODO: Send FCM token to backend
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Handle foreground notification
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // Handle notification tap
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
