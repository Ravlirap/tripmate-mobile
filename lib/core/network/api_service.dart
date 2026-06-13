import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

/// Exceptions thrown by ApiService for descriptive error handling in Providers.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Service that handles HTTP communication with the Laravel backend.
class ApiService {
  final Dio _dio;
  final _secureStorage = const FlutterSecureStorage();

  // Define the base URL. Under Android Emulator, use 10.0.2.2 to access localhost.
  static const String _defaultBaseUrl = kIsWeb
      ? 'http://localhost:8000/api'
      : 'http://10.0.2.2:8000/api'; // Or adjust to your Laragon domain e.g., 'http://trip-mate-backend.test/api'

  String _baseUrl = _defaultBaseUrl;

  ApiService({Dio? dio}) : _dio = dio ?? Dio() {
    _initDio();
  }

  /// Sets custom Base URL dynamically if needed
  void setBaseUrl(String url) {
    _baseUrl = url;
    _dio.options.baseUrl = url;
  }

  String get baseUrl => _baseUrl;

  void _initDio() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    // Add interceptors for Bearer Token injection and Logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Read token from Flutter Secure Storage
          final token = await _secureStorage.read(key: 'sanctum_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            print('--> ${options.method} ${options.uri}');
            print('Headers: ${options.headers}');
            if (options.data != null) {
              print('Body: ${options.data}');
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('<-- ${response.statusCode} ${response.requestOptions.uri}');
            print('Response: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('<-- ERROR ${e.response?.statusCode} ${e.requestOptions.uri}');
            print('Message: ${e.message}');
            print('Response Data: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  // HTTP Wrapper methods that convert DioExceptions into clean ApiExceptions
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.patch(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ApiException('Koneksi internet lambat atau terputus.', statusCode: 408);
    }

    if (error.type == DioExceptionType.connectionError) {
      return ApiException('Tidak dapat terhubung ke server. Pastikan server aktif.', statusCode: 503);
    }

    final response = error.response;
    if (response != null) {
      final statusCode = response.statusCode;
      final responseData = response.data;
      String message = 'Terjadi kesalahan sistem.';

      if (responseData is Map && responseData.containsKey('message')) {
        message = responseData['message'].toString();
      } else if (responseData is Map && responseData.containsKey('errors')) {
        // Laravel Validation Errors
        final errors = responseData['errors'];
        if (errors is Map && errors.isNotEmpty) {
          message = errors.values.first.first.toString();
        }
      }

      return ApiException(message, statusCode: statusCode, data: responseData);
    }

    return ApiException(error.message ?? 'Terjadi kesalahan tidak dikenal.');
  }
}
