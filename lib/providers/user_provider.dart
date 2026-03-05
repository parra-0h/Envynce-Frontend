import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'auth_provider.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return UserService(api);
});

final usersProvider = FutureProvider<List<User>>((ref) async {
  final userService = ref.watch(userServiceProvider);
  return userService.getUsers();
});

final createUserProvider = FutureProvider.family<void, Map<String, dynamic>>((
  ref,
  data,
) async {
  final userService = ref.watch(userServiceProvider);
  await userService.createUser(data);
  ref.invalidate(usersProvider);
});

final updateUserProvider = FutureProvider.family<void, Map<String, dynamic>>((
  ref,
  data,
) async {
  final userService = ref.watch(userServiceProvider);
  final id = data['id'];
  await userService.updateUser(id, data);
  ref.invalidate(usersProvider);

  // If the updated user is the current user, refresh auth state if needed
  // This would usually be handled by reading the updated user back
});

final deleteUserProvider = FutureProvider.family<void, String>((ref, id) async {
  final userService = ref.watch(userServiceProvider);
  await userService.deleteUser(id);
  ref.invalidate(usersProvider);
});
