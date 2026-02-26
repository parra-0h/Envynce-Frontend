import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../widgets/smart_table.dart';
import '../widgets/status_badge.dart';

class _ApiKey {
  final String name;
  final String prefix;
  final String lastUsed;
  final String created;
  final String status;

  _ApiKey(this.name, this.prefix, this.lastUsed, this.created, this.status);
}

class ApiKeysView extends StatelessWidget {
  const ApiKeysView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_ApiKey> keys = [
      _ApiKey(
        'Payment Service Prod',
        'pk_live_...',
        '2 mins ago',
        'Dec 12, 2024',
        'Active',
      ),
      _ApiKey(
        'Staging Cluster',
        'pk_test_...',
        '5 hours ago',
        'Jan 10, 2025',
        'Active',
      ),
      _ApiKey('Dev Laptop', 'pk_dev_...', 'Never', 'Feb 14, 2025', 'Active'),
      _ApiKey(
        'Legacy Key',
        'pk_old_...',
        '30 days ago',
        'Nov 01, 2024',
        'Revoked',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          PageHeader(
            title: 'API Keys',
            description:
                'Manage authentication keys for accessing the Config Service API.',
            actions: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Generate New Key'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SmartTable<_ApiKey>(
              columns: const [
                'Name',
                'Token Prefix',
                'Last Used',
                'Created',
                'Status',
                'Actions',
              ],
              data: keys,
              rowBuilder: (key) => [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.key,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      key.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Text(
                    key.prefix,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  key.lastUsed,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                Text(
                  key.created,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                StatusBadge(
                  label: key.status,
                  type: key.status == 'Active'
                      ? StatusType.success
                      : StatusType.error,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        LucideIcons.copy,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: key.prefix));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied prefix to clipboard'),
                          ),
                        );
                      },
                      tooltip: 'Copy',
                    ),
                    IconButton(
                      icon: const Icon(
                        LucideIcons.rotateCw,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: () {},
                      tooltip: 'Roll Key',
                    ),
                    IconButton(
                      icon: const Icon(
                        LucideIcons.trash2,
                        size: 16,
                        color: AppTheme.errorColor,
                      ),
                      onPressed: () {},
                      tooltip: 'Revoke',
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
}
