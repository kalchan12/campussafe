import 'package:dartz/dartz.dart';

sealed class AppError implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const AppError({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;
}

class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.statusCode,
    super.originalError,
  });

  factory NetworkError.noConnection() => const NetworkError(
        message: 'No internet connection. Please check your network.',
      );

  factory NetworkError.timeout() => const NetworkError(
        message: 'Request timed out. Please try again.',
      );

  factory NetworkError.server([String? message]) => NetworkError(
        message: message ?? 'Server error. Please try again later.',
        statusCode: 500,
      );

  factory NetworkError.unauthorized() => const NetworkError(
        message: 'Session expired. Please login again.',
        statusCode: 401,
      );

  factory NetworkError.forbidden() => const NetworkError(
        message: 'You do not have permission to perform this action.',
        statusCode: 403,
      );

  factory NetworkError.notFound() => const NetworkError(
        message: 'Resource not found.',
        statusCode: 404,
      );
}

class LocationError extends AppError {
  const LocationError({
    required super.message,
    super.originalError,
  });

  factory LocationError.permissionDenied() => const LocationError(
        message: 'Location permission denied. Please enable it in settings.',
      );

  factory LocationError.serviceDisabled() => const LocationError(
        message: 'Location services are disabled. Please enable them.',
      );

  factory LocationError.timeout() => const LocationError(
        message: 'Location request timed out.',
      );

  factory LocationError.accuracyLow() => const LocationError(
        message: 'Location accuracy is too low.',
      );
}

class AuthError extends AppError {
  const AuthError({
    required super.message,
    super.statusCode,
    super.originalError,
  });

  factory AuthError.invalidCredentials() => const AuthError(
        message: 'Invalid email or password.',
      );

  factory AuthError.userNotFound() => const AuthError(
        message: 'No account found with this email.',
      );

  factory AuthError.emailAlreadyInUse() => const AuthError(
        message: 'An account with this email already exists.',
      );

  factory AuthError.weakPassword() => const AuthError(
        message: 'Password is too weak.',
      );

  factory AuthError.sessionExpired() => const AuthError(
        message: 'Session expired. Please login again.',
      );
}

class ValidationError extends AppError {
  final Map<String, String> errors;

  const ValidationError({
    required this.errors,
    super.message = 'Validation failed',
  });
}

class CacheError extends AppError {
  const CacheError({
    required super.message,
    super.originalError,
  });
}

typedef Result<T> = Either<AppError, T>;
