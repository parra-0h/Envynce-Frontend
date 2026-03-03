import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../models/audit_log_model.dart';

final auditLogsProvider = FutureProvider<List<AuditLog>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/audit-logs');
  final List<dynamic> data = response.data['data'] ?? [];
  return data.map((json) => AuditLog.fromJson(json)).toList();
});
