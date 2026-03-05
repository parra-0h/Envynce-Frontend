import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../widgets/smart_table.dart';
import '../widgets/status_badge.dart';
import '../providers/config_provider.dart';
import '../models/api_key_model.dart';

class ApiKeysView extends ConsumerWidget {
  const ApiKeysView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keysAsync = ref.watch(apiKeysProvider);

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
                onPressed: () => _showGenerateDialog(context, ref),
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Generate New Key'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: keysAsync.when(
              data: (keys) => SmartTable<ApiKey>(
                columns: const [
                  'Name',
                  'Token Prefix',
                  'Scope',
                  'Last Used',
                  'Expires',
                  'Status',
                  'Actions',
                ],
                data: keys,
                rowBuilder: (key) => [
                  // Name
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
                  // Prefix
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
                      key.prefix.isNotEmpty ? key.prefix : '—',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                  ),
                  // Scope
                  key.applications.isEmpty
                      ? const Text(
                          'All Apps',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        )
                      : Wrap(
                          spacing: 4,
                          children: key.applications
                              .take(2)
                              .map(
                                (a) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    a.name,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                  // Last Used
                  Text(
                    key.lastUsed != null
                        ? _formatRelative(key.lastUsed!)
                        : 'Never',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  // Expires At
                  key.expiresAt != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('MMM d, y').format(key.expiresAt!),
                              style: TextStyle(
                                color: key.isExpired
                                    ? AppTheme.errorColor
                                    : AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            if (key.isExpired)
                              const Text(
                                'EXPIRED',
                                style: TextStyle(
                                  color: AppTheme.errorColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        )
                      : const Text(
                          'Never',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                  // Status
                  StatusBadge(
                    label: key.isExpired ? 'EXPIRED' : key.status.toUpperCase(),
                    type: (key.status == 'active' && !key.isExpired)
                        ? StatusType.success
                        : StatusType.error,
                  ),
                  // Actions
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
                        tooltip: 'Copy Prefix',
                      ),
                      if (key.status == 'active' && !key.isExpired)
                        IconButton(
                          icon: const Icon(
                            LucideIcons.trash2,
                            size: 16,
                            color: AppTheme.errorColor,
                          ),
                          onPressed: () => _revokeKey(context, ref, key),
                          tooltip: 'Revoke',
                        ),
                    ],
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

  String _formatRelative(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  Future<void> _showGenerateDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    DateTime? selectedExpiry;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Generate API Key'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Key Name',
                  hintText: 'e.g. Production Server',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    LucideIcons.calendar,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedExpiry != null
                          ? 'Expires: ${DateFormat('MMM d, y').format(selectedExpiry!)}'
                          : 'No expiry date (optional)',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 365),
                        ),
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(
                          const Duration(days: 3650),
                        ),
                      );
                      if (date != null) {
                        setState(() => selectedExpiry = date);
                      }
                    },
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      try {
        final payload = <String, dynamic>{'name': nameController.text};
        if (selectedExpiry != null) {
          payload['expires_at'] = selectedExpiry!.toUtc().toIso8601String();
        }
        final newKey = await ref.read(createApiKeyProvider(payload).future);
        if (context.mounted) {
          _showNewKeyDialog(context, newKey);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  void _showNewKeyDialog(BuildContext context, ApiKey key) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: Colors.orange),
            SizedBox(width: 8),
            Text('Save your key'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please copy this key now. For your security, it will not be shown again.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: SelectableText(
                key.key ?? 'Error: Key not returned',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            if (key.expiresAt != null) ...[
              const SizedBox(height: 12),
              Text(
                'Expires: ${DateFormat('MMM d, y').format(key.expiresAt!)}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: key.key ?? ''));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Key copied to clipboard')),
              );
            },
            child: const Text('Copy & Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _revokeKey(
    BuildContext context,
    WidgetRef ref,
    ApiKey key,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke API Key'),
        content: Text(
          'Are you sure you want to revoke "${key.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(revokeApiKeyProvider(key.id).future);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }
}
