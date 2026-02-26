import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': 'secret-key', // From backend config default
      },
    ),
  );

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

  Exception _handleError(DioException e) {
    if (e.response != null) {
      return Exception(
        'API Error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.message}',
      );
    }
    return Exception('Network Error: ${e.message}');
  }
}
