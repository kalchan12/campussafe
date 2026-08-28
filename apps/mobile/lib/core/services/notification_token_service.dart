import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../errors/app_error.dart';

final notificationTokenServiceProvider =
    Provider<NotificationTokenService>((ref) {
  return NotificationTokenService(Env.isConfigured ? Env.supabase : null);
});

/// Manages FCM device token registration in Supabase.
///
/// Design decisions:
/// - One user can have many devices (multiple tokens per user).
/// - A token row is keyed by (user_id, token).
/// - On refresh the old token is marked inactive, the new one is upserted.
/// - The server-side Edge Function reads active tokens to send notifications.
class NotificationTokenService {
  final SupabaseClient? _client;

  NotificationTokenService(this._client);

  bool get _isAvailable => _client != null;

  /// Registers (or refreshes) a device FCM token for the given user.
  Future<Result<void>> registerToken({
    required String userId,
    required String token,
    String platform = 'android',
  }) async {
    if (!_isAvailable) return const Right(null); // silent no-op offline
    try {
      final now = DateTime.now().toIso8601String();
      await _client!.from('notification_tokens').upsert(
        {
          'user_id': userId,
          'token': token,
          'platform': platform,
          'active': true,
          'updated_at': now,
          'last_seen_at': now,
        },
        onConflict: 'user_id, token',
      );
      return const Right(null);
    } catch (e) {
      return Left(NetworkError(message: 'Failed to register token: $e'));
    }
  }

  /// Deactivates all tokens for the current user on this device.
  /// Called on sign-out so the user no longer receives notifications.
  Future<Result<void>> deactivateTokens({
    required String userId,
    required String token,
  }) async {
    if (!_isAvailable) return const Right(null);
    try {
      await _client!
          .from('notification_tokens')
          .update({'active': false, 'updated_at': DateTime.now().toIso8601String()})
          .match({'user_id': userId, 'token': token});
      return const Right(null);
    } catch (e) {
      return Left(NetworkError(message: 'Failed to deactivate token: $e'));
    }
  }
}
