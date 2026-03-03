import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../widgets/smart_table.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audit_provider.dart';
import '../models/audit_log_model.dart';

class AuditLogsView extends ConsumerWidget {
  const AuditLogsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogsProvider);

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
                onPressed: () {},
                icon: const Icon(LucideIcons.download, size: 16),
                label: const Text('Export CSV'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: logsAsync.when(
              data: (logs) => SmartTable<AuditLog>(
                columns: const [
                  'Action',
                  'Resource',
                  'User',
                  'Details',
                  'Timestamp',
                  'Status',
                ],
                data: logs,
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
                  const Text(
                    'Completed',
                    style: TextStyle(color: AppTheme.textSecondary),
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
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
