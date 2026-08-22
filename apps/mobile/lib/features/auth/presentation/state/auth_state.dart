import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final bool isAuthenticated;
  final bool isGuest;
  final String? userId;
  final String? email;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.isGuest = false,
    this.userId,
    this.email,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    bool? isGuest,
    String? userId,
    String? email,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isGuest: isGuest ?? this.isGuest,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isAuthenticated,
        isGuest,
        userId,
        email,
        error,
      ];
}
