import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../constants/api_constants.dart';
import '../constants/constants.dart';
import '../errors/app_error.dart';
import '../storage/secure_storage_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return DioClient.create(secureStorage);
});

class DioClient {
  static Dio create(SecureStorageService secureStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: '${Env.supabaseUrl}${ApiConstants.apiVersion}',
        connectTimeout: AppConstants.networkTimeout,
        receiveTimeout: AppConstants.networkTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(secureStorage),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);

    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  _AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final response = await Dio().post(
            '${Env.supabaseUrl}${ApiConstants.refreshToken}',
            data: {'refresh_token': refreshToken},
          );
          final newToken = response.data['access_token'];
          await _secureStorage.saveToken(newToken);
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await Dio().fetch(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        } catch (_) {
          await _secureStorage.clearAll();
        }
      }
    }
    handler.next(err);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final error = _mapDioError(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        error: error,
        message: error.message,
      ),
    );
  }

  AppError _mapDioError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkError.timeout();
      case DioExceptionType.connectionError:
        return NetworkError.noConnection();
      case DioExceptionType.badResponse:
        return _handleBadResponse(err.response?.statusCode);
      default:
        return NetworkError(message: err.message ?? 'Unknown error');
    }
  }

  AppError _handleBadResponse(int? statusCode) {
    switch (statusCode) {
      case 401:
        return NetworkError.unauthorized();
      case 403:
        return NetworkError.forbidden();
      case 404:
        return NetworkError.notFound();
      case 500:
        return NetworkError.server();
      default:
        return NetworkError(
          message: 'Server error ($statusCode)',
          statusCode: statusCode,
        );
    }
  }
}
