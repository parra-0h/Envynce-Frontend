import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080/api/v1/',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  String? _token;

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          // The x-api-key might be needed for some endpoints or as a fallback
          options.headers['x-api-key'] = 'secret-key';
          return handler.next(options);
        },
      ),
    );
  }

  void setToken(String? token) {
    _token = token;
  }

  String _normalizePath(String path) {
    // If path starts with /, remove it to prevent Dio from treating it as root path
    return path.startsWith('/') ? path.substring(1) : path;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(
        _normalizePath(path),
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, dynamic data) async {
    try {
      return await _dio.post(_normalizePath(path), data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, dynamic data) async {
    try {
      return await _dio.put(_normalizePath(path), data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(_normalizePath(path));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      String? message;
      if (e.response?.data is Map) {
        message = e.response?.data['message'] ?? e.response?.data['error'];
      } else if (e.response?.data is String &&
          (e.response?.data as String).length < 100) {
        message = e.response?.data as String;
      }

      message ??= e.message;
      return Exception('API Error: ${e.response?.statusCode} - $message');
    }
    return Exception('Network Error: ${e.message}');
  }
}
