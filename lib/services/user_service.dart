import '../services/api_service.dart';
import '../models/user_model.dart';

class UserService {
  final ApiService _api;

  UserService(this._api);

  Future<List<User>> getUsers() async {
    final response = await _api.get('/users');
    final List<dynamic> data = response.data is List
        ? response.data
        : (response.data['data'] as List<dynamic>? ?? []);
    return data.map((u) => User.fromJson(u)).toList();
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    await _api.post('/users', data);
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _api.put('/users/$id', data);
  }

  Future<void> deleteUser(String id) async {
    await _api.delete('/users/$id');
  }
}
