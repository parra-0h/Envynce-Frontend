import '../models/auth_response.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final data = response.data['data'] ?? response.data;
    return AuthResponse.fromJson(data);
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout', {});
    } catch (e) {
      // Even if API logout fails, we want to clear local state
      print('Logout API call failed: $e');
    }
  }

  Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await _apiService.post('/auth/refresh', {
      'refresh_token': refreshToken,
    });

    final data = response.data['data'] ?? response.data;
    return AuthResponse.fromJson(data);
  }
}
