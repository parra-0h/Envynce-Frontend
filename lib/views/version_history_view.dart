import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../widgets/smart_table.dart';

class _HistoryItem {
  final String entity;
  final String version;
  final String changeType;
  final String user;
  final DateTime date;
  final String description;

  _HistoryItem(
    this.entity,
    this.version,
    this.changeType,
    this.user,
    this.date,
    this.description,
  );
}

class VersionHistoryView extends StatelessWidget {
  const VersionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_HistoryItem> history = [
      _HistoryItem(
        'FEATURE_DARK_MODE',
        'v1.0.2',
        'UPDATE',
        'admin@company.com',
        DateTime.now().subtract(const Duration(minutes: 10)),
        'Changed value from false to true',
      ),
      _HistoryItem(
        'API_RATE_LIMIT',
        'v2.1.0',
        'CREATE',
        'system',
        DateTime.now().subtract(const Duration(hours: 1)),
        'Initial creation',
      ),
      _HistoryItem(
        'MAINTENANCE_MODE',
        'v0.9.5',
        'DELETE',
        'dev@company.com',
        DateTime.now().subtract(const Duration(days: 1)),
        'Removed obsolete flag',
      ),
      _HistoryItem(
        'PAYMENT_GATEWAY',
        'v3.0.0',
        'UPDATE',
        'admin@company.com',
        DateTime.now().subtract(const Duration(days: 2)),
        'Updated API endpoint',
      ),
      _HistoryItem(
        'MAX_UPLOAD_SIZE',
        'v1.0.1',
        'UPDATE',
        'ops@company.com',
        DateTime.now().subtract(const Duration(days: 5)),
        'Increased limit to 50MB',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const PageHeader(
            title: 'Version History',
            description:
                'Audit trail of all configuration changes in the system.',
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SmartTable<_HistoryItem>(
              columns: const [
                'Entity',
                'Ver',
                'Change',
                'User',
                'Date',
                'Description',
                '',
              ],
              data: history,
              rowBuilder: (item) => [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.fileCode,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.entity,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  item.version,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                _buildChangeType(item.changeType),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 8,
                      backgroundColor: AppTheme.textTertiary,
                      child: Icon(Icons.person, size: 10, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.user.split('@')[0],
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                Text(
                  DateFormat('MMM d, HH:mm').format(item.date),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  item.description,
                  style: const TextStyle(color: AppTheme.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('View Diff'),
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

  Widget _buildChangeType(String type) {
    Color color;
    IconData icon;
    switch (type) {
      case 'CREATE':
        color = AppTheme.successColor;
        icon = LucideIcons.plus;
        break;
      case 'UPDATE':
        color = AppTheme.warningColor;
        icon = LucideIcons.edit2;
        break;
      case 'DELETE':
        color = AppTheme.errorColor;
        icon = LucideIcons.trash;
        break;
      default:
        color = AppTheme.textSecondary;
        icon = LucideIcons.info;
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          type,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
