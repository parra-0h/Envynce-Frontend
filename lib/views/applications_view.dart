import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../widgets/smart_table.dart';
import '../widgets/status_badge.dart';

class _Application {
  final String name;
  final String id;
  final String owner;
  final String status;
  final DateTime lastDeployed;

  _Application(this.name, this.id, this.owner, this.status, this.lastDeployed);
}

class ApplicationsView extends StatelessWidget {
  const ApplicationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_Application> apps = [
      _Application(
        'Payment Service',
        'svc-payment',
        'payments-team',
        'Active',
        DateTime.now(),
      ),
      _Application(
        'User Service',
        'svc-user',
        'platform-team',
        'Active',
        DateTime.now().subtract(const Duration(hours: 2)),
      ),
      _Application(
        'Notification Worker',
        'wkr-notify',
        'platform-team',
        'Warning',
        DateTime.now().subtract(const Duration(days: 1)),
      ),
      _Application(
        'Audit Logger',
        'svc-audit',
        'info-sec',
        'Active',
        DateTime.now().subtract(const Duration(days: 3)),
      ),
      _Application(
        'Legacy API',
        'api-v1',
        'legacy-team',
        'Inactive',
        DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          PageHeader(
            title: 'Applications',
            description: 'Manage registered applications and their access.',
            actions: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.download, size: 16),
                label: const Text('Export'),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('New Application'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SmartTable<_Application>(
              columns: const [
                'Name',
                'Service ID',
                'Owner',
                'Status',
                'Last Deployed',
                '',
              ],
              data: apps,
              rowBuilder: (app) => [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        LucideIcons.box,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      app.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  app.id,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  app.owner,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                StatusBadge(
                  label: app.status,
                  type: _getStatusType(app.status),
                ),
                Text(
                  '2 hours ago', // Mock
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        LucideIcons.moreHorizontal,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  StatusType _getStatusType(String status) {
    switch (status) {
      case 'Active':
        return StatusType.success;
      case 'Warning':
        return StatusType.warning;
      case 'Inactive':
        return StatusType.neutral;
      default:
        return StatusType.neutral;
    }
  }
}
