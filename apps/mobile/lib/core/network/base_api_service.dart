import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../errors/app_error.dart';

abstract class BaseApiService {
  final Dio dio;

  BaseApiService(this.dio);

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
      );
      if (fromJson != null) {
        return Right(fromJson(response.data));
      }
      return Right(response.data as T);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(NetworkError(message: e.toString()));
    }
  }

  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      if (fromJson != null) {
        return Right(fromJson(response.data));
      }
      return Right(response.data as T);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(NetworkError(message: e.toString()));
    }
  }

  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      if (fromJson != null) {
        return Right(fromJson(response.data));
      }
      return Right(response.data as T);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(NetworkError(message: e.toString()));
    }
  }

  Future<Result<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await dio.delete(
        path,
        queryParameters: queryParameters,
      );
      if (fromJson != null) {
        return Right(fromJson(response.data));
      }
      return Right(response.data as T);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(NetworkError(message: e.toString()));
    }
  }

  AppError _handleError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkError.timeout();
      case DioExceptionType.connectionError:
        return NetworkError.noConnection();
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == 401) return NetworkError.unauthorized();
        if (statusCode == 403) return NetworkError.forbidden();
        if (statusCode == 404) return NetworkError.notFound();
        return NetworkError.server();
      default:
        return NetworkError(message: err.message ?? 'Unknown error');
    }
  }
}
