import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../../core/config/env.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../shared/models/user.dart' as app;

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Env.isConfigured ? Env.supabase : null);
});

class AuthRepository {
  final supa.SupabaseClient? _client;

  AuthRepository(this._client);

  bool get _isAvailable => _client != null;

  // ---------- Auth ----------

  Future<Result<app.User>> signIn({
    required String email,
    required String password,
  }) async {
    if (!_isAvailable) return Left(NetworkError.noConnection());
    try {
      final response = await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        return const Left(AuthError(message: 'Sign-in failed'));
      }
      final profileResult = await _fetchProfile(response.user!.id);
      return profileResult.fold(
        (_) => Right(app.User(
          id: response.user!.id,
          email: response.user!.email ?? email,
          fullName: response.user!.userMetadata?['full_name'] as String? ?? email.split('@').first,
          role: app.UserRole.fromString(response.user!.userMetadata?['role'] as String? ?? 'student'),
          createdAt: DateTime.tryParse(response.user!.createdAt) ?? DateTime.now(),
          updatedAt: DateTime.now(),
        )),
        (user) => Right(user),
      );
    } on supa.AuthException catch (e) {
      return Left(AuthError(message: e.message));
    } catch (e) {
      return Left(AuthError(message: e.toString()));
    }
  }

  Future<Result<app.User>> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? role,
    String? campusBlock,
  }) async {
    if (!_isAvailable) return Left(NetworkError.noConnection());
    try {
      final response = await _client!.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          if (phone != null) 'phone': phone,
        },
      );
      if (response.user == null) {
        return const Left(AuthError(message: 'Registration failed'));
      }
      // Upsert the profile row (also handled by the DB trigger, but
      // explicit upsert ensures campus_block and role are captured)
      try {
        await _client!.from('profiles').upsert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'phone': phone,
          'role': role ?? 'student',
          'campus_block': campusBlock,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // DB trigger fallback
      }
      final profileResult = await _fetchProfile(response.user!.id);
      return profileResult.fold(
        (_) => Right(app.User(
          id: response.user!.id,
          email: email,
          fullName: fullName,
          phone: phone,
          role: app.UserRole.fromString(role ?? 'student'),
          campusBlock: campusBlock,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )),
        (user) => Right(user),
      );
    } on supa.AuthException catch (e) {
      return Left(AuthError(message: e.message));
    } catch (e) {
      return Left(AuthError(message: e.toString()));
    }
  }

  Future<Result<void>> signOut() async {
    if (!_isAvailable) return const Right(null);
    try {
      await _client!.auth.signOut();
      return const Right(null);
    } on supa.AuthException catch (e) {
      return Left(AuthError(message: e.message));
    } catch (e) {
      return Left(AuthError(message: e.toString()));
    }
  }

  Future<Result<void>> sendPasswordResetEmail(String email) async {
    if (!_isAvailable) return Left(NetworkError.noConnection());
    try {
      await _client!.auth.resetPasswordForEmail(email);
      return const Right(null);
    } on supa.AuthException catch (e) {
      return Left(AuthError(message: e.message));
    } catch (e) {
      return Left(AuthError(message: e.toString()));
    }
  }

  supa.User? get currentUser => _client?.auth.currentUser;

  Stream<supa.AuthState> get authStateChanges =>
      _client?.auth.onAuthStateChange ?? const Stream.empty();

  // ---------- Profile helpers ----------

  Future<Result<app.User>> _fetchProfile(String userId) async {
    try {
      final data = await _client!
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return Right(app.User.fromJson(data));
    } catch (e) {
      return Left(AuthError(message: 'Failed to load profile: $e'));
    }
  }

  Future<Result<app.User>> getCurrentUserProfile() async {
    if (!_isAvailable) return Left(NetworkError.noConnection());
    final user = _client!.auth.currentUser;
    if (user == null) {
      return const Left(AuthError(message: 'Not authenticated'));
    }
    return _fetchProfile(user.id);
  }
}
