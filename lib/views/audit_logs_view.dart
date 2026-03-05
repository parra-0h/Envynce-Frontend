import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../widgets/smart_table.dart';
import '../providers/audit_provider.dart';
import '../models/audit_log_model.dart';

class AuditLogsView extends HookConsumerWidget {
  const AuditLogsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogsProvider);
    final searchController = useTextEditingController();
    final searchQuery = useValueListenable(searchController);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const PageHeader(
            title: 'Audit Logs',
            description:
                'Comprehensive log of all system activities for security and compliance.',
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search logs...',
                    prefixIcon: Icon(
                      LucideIcons.search,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.filter, size: 16),
                label: const Text('Filter'),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: logsAsync.when(
                  data: (logs) =>
                      () => _exportToCSV(context, logs),
                  loading: () => null,
                  error: (_, _) => null,
                ),
                icon: const Icon(LucideIcons.download, size: 16),
                label: const Text('Export CSV'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: logsAsync.when(
              data: (logs) {
                final query = searchQuery.text.toLowerCase();
                final filteredLogs = logs.where((log) {
                  return log.action.toLowerCase().contains(query) ||
                      log.entity.toLowerCase().contains(query) ||
                      log.changedBy.toLowerCase().contains(query) ||
                      log.entityId.toString().contains(query);
                }).toList();

                return SmartTable<AuditLog>(
                  columns: const [
                    'Action',
                    'Resource',
                    'User',
                    'Timestamp',
                    'Status',
                  ],
                  data: filteredLogs,
                  rowBuilder: (log) => [
                    Text(
                      log.action,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${log.entity} #${log.entityId}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      log.changedBy,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createdAt),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Success',
                        style: TextStyle(
                          color: AppTheme.successColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _exportToCSV(BuildContext context, List<AuditLog> logs) {
    final buffer = StringBuffer();
    buffer.writeln('Action,Resource,User,Timestamp');
    for (final log in logs) {
      buffer.writeln(
        '${log.action},"${log.entity} #${log.entityId}",${log.changedBy},${DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createdAt)}',
      );
    }

    // In a real application, we would use a package like 'file_picker' or 'url_launcher'
    // to save the file. For now, we'll simulate the download.
    debugPrint('CSV Export Generated:\n${buffer.toString()}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV Exported to console (Simulation)'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
