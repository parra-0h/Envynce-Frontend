import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../widgets/smart_table.dart';

class _AuditLog {
  final String action;
  final String resource;
  final String user;
  final String ip;
  final DateTime timestamp;
  final String status;

  _AuditLog(
    this.action,
    this.resource,
    this.user,
    this.ip,
    this.timestamp,
    this.status,
  );
}

class AuditLogsView extends StatelessWidget {
  const AuditLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_AuditLog> logs = [
      _AuditLog(
        'UPDATE_CONFIG',
        'feature_flags.ui',
        'admin@company.com',
        '192.168.1.1',
        DateTime.now().subtract(const Duration(minutes: 5)),
        'Success',
      ),
      _AuditLog(
        'CREATE_APP',
        'svc-payment',
        'system',
        '10.0.0.1',
        DateTime.now().subtract(const Duration(hours: 2)),
        'Success',
      ),
      _AuditLog(
        'REVOKE_KEY',
        'pk_test_123',
        'admin@company.com',
        '192.168.1.1',
        DateTime.now().subtract(const Duration(hours: 4)),
        'Success',
      ),
      _AuditLog(
        'LOGIN_FAILED',
        'auth.login',
        'unknown',
        '123.45.67.89',
        DateTime.now().subtract(const Duration(hours: 12)),
        'Failed',
      ),
      _AuditLog(
        'DELETE_ENV',
        'staging-2',
        'dev@company.com',
        '172.16.0.5',
        DateTime.now().subtract(const Duration(days: 1)),
        'Success',
      ),
    ];

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
                    hintText: 'Search logs (user, resource, IP)...',
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
                label: const Text('Filter by Date'),
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
            child: SmartTable<_AuditLog>(
              columns: const [
                'Action',
                'Resource',
                'User',
                'IP Address',
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
                  log.resource,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  log.user,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                Text(
                  log.ip,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.textTertiary,
                  ),
                ),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(log.timestamp),
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
                    color: log.status == 'Success'
                        ? AppTheme.successColor.withValues(alpha: 0.1)
                        : AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.status,
                    style: TextStyle(
                      color: log.status == 'Success'
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
