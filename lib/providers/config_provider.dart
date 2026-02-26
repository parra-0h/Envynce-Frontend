import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/api_service.dart';
import '../models/configuration_model.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final applicationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/applications');
  return response.data['data'] ?? [];
});

final environmentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/environments');
  return response.data['data'] ?? [];
});

final configurationsProvider =
    FutureProvider.family<List<ConfigurationItem>, Map<String, int>>((
      ref,
      params,
    ) async {
      final api = ref.watch(apiServiceProvider);
      final response = await api.get(
        '/configs',
        queryParameters: {
          'application_id': params['application_id'],
          'environment_id': params['environment_id'],
        },
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data
          .map(
            (json) => ConfigurationItem(
              id: json['id'].toString(),
              key: json['key'],
              value: json['value'],
              environment: json['environment_id']
                  .toString(), // Simplified for now
              version: json['version'] ?? '1.0.0',
              lastUpdated:
                  DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
              isActive: json['is_active'] ?? true,
            ),
          )
          .toList();
    });
