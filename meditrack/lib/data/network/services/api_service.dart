import 'package:dio/dio.dart';
import '../../../config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// API Service
///
/// A reusable API client built on Dio that provides generic methods
/// for GET, POST, PUT, DELETE operations. Includes interceptors for
/// authentication, logging, and error handling.
class ApiService {
  ApiService._();

  static ApiService? _instance;
  static Dio? _dio;

  /// Get singleton instance
  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  /// Initialize Dio client with base configuration
  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.apiTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.apiTimeout),
        headers: {
          'Content-Type': AppConstants.apiContentType,
          'Accept': AppConstants.apiAcceptHeader,
        },
      ),
    );

    // Add interceptors
    _dio!.interceptors.addAll([
      LoggingInterceptor(),
      AuthInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  /// Get Dio instance
  Dio get dio {
    if (_dio == null) {
      initialize();
    }
    return _dio!;
  }

  /// Generic GET request
  ///
  /// [path] - API endpoint path
  /// [queryParameters] - Query parameters
  /// [options] - Additional request options
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generic POST request
  ///
  /// [path] - API endpoint path
  /// [data] - Request body data
  /// [queryParameters] - Query parameters
  /// [options] - Additional request options
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generic PUT request
  ///
  /// [path] - API endpoint path
  /// [data] - Request body data
  /// [queryParameters] - Query parameters
  /// [options] - Additional request options
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generic DELETE request
  ///
  /// [path] - API endpoint path
  /// [data] - Request body data
  /// [queryParameters] - Query parameters
  /// [options] - Additional request options
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
}
