import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../models/configuration_model.dart';
import '../models/app_model.dart';
import '../models/api_key_model.dart';

// Selection State
class SelectedApplication extends Notifier<Application?> {
  @override
  Application? build() => null;
  void set(Application? app) {
    debugPrint('[DEBUG-V2] SETTING APP: ${app?.name} (id: ${app?.id})');
    state = app;
  }
}

final selectedApplicationProvider =
    NotifierProvider<SelectedApplication, Application?>(
      SelectedApplication.new,
    );

class SelectedEnvironment extends Notifier<Environment?> {
  @override
  Environment? build() => null;
  void set(Environment? env) {
    debugPrint('[DEBUG-V2] SETTING ENV: ${env?.name} (id: ${env?.id})');
    state = env;
  }
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

class ConfigSearchQuery extends Notifier<String> {
  @override
  String build() => '';
  void set(String query) => state = query;
}

final configSearchQueryProvider = NotifierProvider<ConfigSearchQuery, String>(
  ConfigSearchQuery.new,
);

// Configurations
final configurationsProvider = FutureProvider<List<ConfigurationItem>>((
  ref,
) async {
  ref.keepAlive();
  ref.onDispose(
    () => debugPrint('[DEBUG-V2] DISPOSING configurationsProvider'),
  );

  final appId = ref.watch(selectedApplicationProvider.select((app) => app?.id));
  final envId = ref.watch(selectedEnvironmentProvider.select((env) => env?.id));
  final searchQuery = ref.watch(configSearchQueryProvider);

  debugPrint(
    '[DEBUG-V2] FETCHING CONFIGS: app=$appId, env=$envId, search=$searchQuery',
  );

  if (appId == null || envId == null) {
    return [];
  }

  final api = ref.read(apiServiceProvider);
  final response = await api.get(
    '/configs',
    queryParameters: {
      'application_id': appId,
      'environment_id': envId,
      if (searchQuery.isNotEmpty) 'search': searchQuery,
    },
  );

  final List<dynamic> data = response.data['data'] ?? [];
  return data.map((json) => ConfigurationItem.fromJson(json)).toList();
});

// Configuration Versions
final configVersionsProvider =
    FutureProvider.family<List<ConfigVersion>, String>((ref, configId) async {
      debugPrint('[DEBUG-V2] FETCHING VERSIONS for config: $configId');
      final api = ref.watch(apiServiceProvider);
      final response = await api.get('/configs/$configId/versions');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => ConfigVersion.fromJson(json)).toList();
    });

// API Keys
final apiKeysProvider = FutureProvider<List<ApiKey>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/api-keys');
  final List<dynamic> data = response.data['data'] ?? [];
  return data.map((json) => ApiKey.fromJson(json)).toList();
});

/// Accepts a map with 'name' and optional 'expires_at' (ISO8601 string)
final createApiKeyProvider =
    FutureProvider.family<ApiKey, Map<String, dynamic>>((ref, payload) async {
      final api = ref.watch(apiServiceProvider);
      final response = await api.post('/api-keys', payload);
      ref.invalidate(apiKeysProvider);
      return ApiKey.fromJson(response.data['data'] ?? response.data);
    });

final revokeApiKeyProvider = FutureProvider.family<void, String>((
  ref,
  id,
) async {
  final api = ref.watch(apiServiceProvider);
  await api.delete('/api-keys/$id');
  ref.invalidate(apiKeysProvider);
});

// Metrics: requests per minute (last 24h)
final metricsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/metrics/requests-per-minute');
  final List<dynamic> data = response.data is List
      ? response.data as List<dynamic>
      : (response.data['data'] as List<dynamic>? ?? []);
  return data.cast<Map<String, dynamic>>();
});

final restoreConfigVersionProvider = FutureProvider.family<void, String>((
  ref,
  versionId,
) async {
  final api = ref.watch(apiServiceProvider);
  await api.post('/configs/versions/$versionId/restore', {});

  // Invalidate relevant providers to refresh UI
  ref.invalidate(configurationsProvider);
  // We also need to invalidate the versions provider for the parent config
  // but we don't know the configId here easily without extra params.
  // However, the history view will probably refresh when it's re-entered
  // or we can invalidate all families if needed.
  ref.invalidate(configVersionsProvider);
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

final updateApplicationProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, data) async {
      final api = ref.watch(apiServiceProvider);
      final id = data['id'];
      await api.put('/applications/$id', data);
      ref.invalidate(applicationsProvider);
    });

final deleteApplicationProvider = FutureProvider.family<void, String>((
  ref,
  id,
) async {
  final api = ref.watch(apiServiceProvider);
  await api.delete('/applications/$id');
  ref.invalidate(applicationsProvider);
});

final createEnvironmentProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, data) async {
      final api = ref.watch(apiServiceProvider);
      await api.post('/environments', data);
      ref.invalidate(environmentsProvider);
    });

final updateEnvironmentProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, data) async {
      final api = ref.watch(apiServiceProvider);
      final id = data['id'];
      await api.put('/environments/$id', data);
      ref.invalidate(environmentsProvider);
    });

final deleteEnvironmentProvider = FutureProvider.family<void, String>((
  ref,
  id,
) async {
  final api = ref.watch(apiServiceProvider);
  await api.delete('/environments/$id');
  ref.invalidate(environmentsProvider);
});
