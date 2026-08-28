import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../../../core/config/env.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../shared/models/user.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Env.isConfigured ? Env.supabase : null);
});

class ProfileRepository {
  final SupabaseClient? _client;

  ProfileRepository(this._client);

  bool get _isAvailable => _client != null;

  Future<Result<User>> getProfile(String userId) async {
    if (!_isAvailable) return Left(NetworkError.noConnection());
    try {
      final data = await _client!
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return Right(User.fromJson(data));
    } catch (e) {
      return Left(NetworkError(message: 'Failed to load profile: $e'));
    }
  }

  Future<Result<User>> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? campusBlock,
    String? emergencyInfo,
  }) async {
    if (!_isAvailable) return Left(NetworkError.noConnection());
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
        if (campusBlock != null) 'campus_block': campusBlock,
        if (emergencyInfo != null) 'emergency_info': emergencyInfo,
      };
      final data = await _client!
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();
      return Right(User.fromJson(data));
    } catch (e) {
      return Left(NetworkError(message: 'Failed to update profile: $e'));
    }
  }
}
