import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../models/configuration_model.dart';
import '../models/app_model.dart';

// Selection State
class SelectedApplication extends Notifier<Application?> {
  @override
  Application? build() => null;
  void set(Application? app) => state = app;
}

final selectedApplicationProvider =
    NotifierProvider<SelectedApplication, Application?>(
      SelectedApplication.new,
    );

class SelectedEnvironment extends Notifier<Environment?> {
  @override
  Environment? build() => null;
  void set(Environment? env) => state = env;
}

final selectedEnvironmentProvider =
    NotifierProvider<SelectedEnvironment, Environment?>(
      SelectedEnvironment.new,
    );

// Applications
final applicationsProvider = FutureProvider<List<Application>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/applications');
  final List<dynamic> data = response.data['data'] ?? [];
  return data.map((json) => Application.fromJson(json)).toList();
});

// Environments
final environmentsProvider = FutureProvider<List<Environment>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/environments');
  final List<dynamic> data = response.data['data'] ?? [];
  return data.map((json) => Environment.fromJson(json)).toList();
});

// Configurations
final configurationsProvider =
    FutureProvider.family<List<ConfigurationItem>, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final api = ref.watch(apiServiceProvider);
      final response = await api.get(
        '/configs',
        queryParameters: {
          if (params['application_id'] != null)
            'application_id': params['application_id'],
          if (params['environment_id'] != null)
            'environment_id': params['environment_id'],
          if (params['search'] != null) 'search': params['search'],
        },
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => ConfigurationItem.fromJson(json)).toList();
    });

// Configuration Versions
final configVersionsProvider =
    FutureProvider.family<List<ConfigVersion>, String>((ref, configId) async {
      final api = ref.watch(apiServiceProvider);
      final response = await api.get('/configs/$configId/versions');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => ConfigVersion.fromJson(json)).toList();
    });

// CRUD Mutations
final saveConfigurationProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, data) async {
      final api = ref.watch(apiServiceProvider);
      final id = data['id'];

      if (id == null) {
        await api.post('/configs', data);
      } else {
        await api.put('/configs/$id', data);
      }

      ref.invalidate(configurationsProvider);
    });

final deleteConfigurationProvider = FutureProvider.family<void, String>((
  ref,
  id,
) async {
  final api = ref.watch(apiServiceProvider);
  await api.delete('/configs/$id');
  ref.invalidate(configurationsProvider);
});

final createApplicationProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, data) async {
      final api = ref.watch(apiServiceProvider);
      await api.post('/applications', data);
      ref.invalidate(applicationsProvider);
    });
