import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080',
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

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, dynamic data) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, dynamic data) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
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
