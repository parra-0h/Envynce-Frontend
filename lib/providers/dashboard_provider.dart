import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class DashboardStats {
  final int totalApps;
  final int totalConfigs;
  final int activeConfigs;
  final int totalEnvironments;
  final List<dynamic> updates;

  DashboardStats({
    required this.totalApps,
    required this.totalConfigs,
    required this.activeConfigs,
    required this.totalEnvironments,
    required this.updates,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalApps: json['total_apps'] ?? 0,
      totalConfigs: json['total_configs'] ?? 0,
      activeConfigs: json['active_configs'] ?? 0,
      totalEnvironments: json['total_environments'] ?? 0,
      updates: json['recent_updates'] ?? [],
    );
  }
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/dashboard/stats');
  final data = response.data['data'] ?? response.data;
  return DashboardStats.fromJson(data);
});
