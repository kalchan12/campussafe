import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env.dart';
import '../../../../shared/models/user.dart';
import '../../../auth/presentation/state/auth_notifier.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileState extends Equatable {
  final User? user;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  const ProfileState({
    this.user,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  ProfileState copyWith({
    User? user,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [user, isLoading, isSaving, error, successMessage];
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(ref, repository);
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref _ref;
  final ProfileRepository _repository;

  ProfileNotifier(this._ref, this._repository) : super(const ProfileState()) {
    // Listen for auth changes to reload profile (e.g. after login/logout)
    _ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (previous?.userId != next.userId || previous?.isAuthenticated != next.isAuthenticated) {
        loadProfile();
      }
    });
    
    // Initial load
    loadProfile();
  }

  Future<void> loadProfile() async {
    final authState = _ref.read(authNotifierProvider);
    final userId = authState.userId;

    if (userId == null) {
      // Unauthenticated or Guest fallback
      state = state.copyWith(
        isLoading: false,
        user: User(
          id: 'usr_guest',
          email: authState.email ?? 'guest@campus.edu',
          fullName: 'Campus Guest / Student',
          role: UserRole.student,
          campusBlock: 'Main Campus',
          emergencyInfo: 'Blood Type: O+ | Allergies: None recorded | ICE: Campus Police (911)',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    if (Env.isConfigured) {
      final result = await _repository.getProfile(userId);
      result.fold(
        (error) {
          state = state.copyWith(
            isLoading: false,
            error: error.message,
            user: _buildFallbackUser(userId, authState.email),
          );
        },
        (user) {
          state = state.copyWith(
            isLoading: false,
            user: user,
            error: null,
          );
        },
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        user: _buildFallbackUser(userId, authState.email),
      );
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? campusBlock,
    String? emergencyInfo,
  }) async {
    final currentUser = state.user;
    if (currentUser == null) return false;

    state = state.copyWith(isSaving: true, error: null, successMessage: null);

    if (Env.isConfigured) {
      final result = await _repository.updateProfile(
        userId: currentUser.id,
        fullName: fullName,
        phone: phone,
        campusBlock: campusBlock,
        emergencyInfo: emergencyInfo,
      );

      return result.fold(
        (error) {
          state = state.copyWith(
            isSaving: false,
            error: error.message,
          );
          return false;
        },
        (updatedUser) {
          state = state.copyWith(
            isSaving: false,
            user: updatedUser,
            successMessage: 'Profile & Safety ID updated successfully',
          );
          return true;
        },
      );
    } else {
      // Local dev optimistic update
      await Future.delayed(const Duration(milliseconds: 400));
      final updatedUser = currentUser.copyWith(
        fullName: fullName,
        phone: phone,
        campusBlock: campusBlock,
        emergencyInfo: emergencyInfo,
        updatedAt: DateTime.now(),
      );
      state = state.copyWith(
        isSaving: false,
        user: updatedUser,
        successMessage: 'Profile & Safety ID updated successfully',
      );
      return true;
    }
  }

  User _buildFallbackUser(String userId, String? email) {
    return User(
      id: userId,
      email: email ?? 'student@campus.edu',
      fullName: email != null ? email.split('@').first.toUpperCase() : 'Campus User',
      phone: '+1 (555) 123-4567',
      role: UserRole.student,
      campusBlock: 'Engineering Quad - Building 2',
      emergencyInfo: 'Blood Type: O+ | Allergies: Penicillin | Asthmatic | ICE: +1 (555) 999-0000',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
