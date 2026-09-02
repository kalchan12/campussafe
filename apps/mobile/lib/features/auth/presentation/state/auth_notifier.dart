import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../../core/config/env.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final notifService = ref.watch(notificationServiceProvider);
  return AuthNotifier(repo, notifService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final NotificationService _notifService;

  AuthNotifier(this._repo, this._notifService) : super(const AuthState()) {
    _init();
  }

  void _init() {
    // Reflect any existing session on app start
    if (Env.isConfigured) {
      final currentUser = Env.supabase.auth.currentUser;
      if (currentUser != null) {
        state = state.copyWith(
          isAuthenticated: true,
          userId: currentUser.id,
          email: currentUser.email,
        );
        _notifService.associateTokenWithUser(currentUser.id);
      }

      // Listen for background session changes (sign-out, token refresh)
      Env.supabase.auth.onAuthStateChange.listen((event) {
        if (event.event == supa.AuthChangeEvent.signedOut) {
          state = const AuthState();
        } else if (event.event == supa.AuthChangeEvent.tokenRefreshed) {
          final user = event.session?.user;
          if (user != null) {
            state = state.copyWith(
              isAuthenticated: true,
              isGuest: false,
              userId: user.id,
              email: user.email,
            );
          }
        }
      });
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.signIn(email: email, password: password);
    result.fold(
      (err) => state = state.copyWith(isLoading: false, error: err.message),
      (user) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          isGuest: false,
          userId: user.id,
          email: user.email,
          error: null,
        );
        _notifService.associateTokenWithUser(user.id);
      },
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? role,
    String? campusBlock,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      role: role,
      campusBlock: campusBlock,
    );
    result.fold(
      (err) => state = state.copyWith(isLoading: false, error: err.message),
      (user) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          isGuest: false,
          userId: user.id,
          email: user.email,
          error: null,
        );
        _notifService.associateTokenWithUser(user.id);
      },
    );
  }

  Future<void> signOut() async {
    final userId = state.userId;
    if (userId != null) {
      await _notifService.disassociateToken(userId);
    }
    await _repo.signOut();
    state = const AuthState();
  }

  Future<void> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.sendPasswordResetEmail(email);
    result.fold(
      (err) => state = state.copyWith(isLoading: false, error: err.message),
      (_) => state = state.copyWith(isLoading: false, error: null),
    );
  }

  void enterGuestMode() {
    state = state.copyWith(isGuest: true, isAuthenticated: false, error: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
