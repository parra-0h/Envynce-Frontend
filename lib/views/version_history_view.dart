import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../widgets/smart_table.dart';
import '../providers/config_provider.dart';
import '../models/configuration_model.dart';

class VersionHistoryView extends ConsumerWidget {
  const VersionHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = GoRouterState.of(context);
    final configId = state.uri.queryParameters['id'];
    final configKey = state.uri.queryParameters['key'];

    final versionsAsync = configId != null
        ? ref.watch(configVersionsProvider(configId))
        : const AsyncValue.data(<ConfigVersion>[]);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          PageHeader(
            title: configKey != null
                ? 'History: $configKey'
                : 'Version History',
            description: configKey != null
                ? 'Revision history for this configuration key.'
                : 'Audit trail of configuration changes.',
            actions: [
              if (configId != null)
                TextButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(LucideIcons.arrowLeft, size: 16),
                  label: const Text('Back'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: versionsAsync.when(
              data: (versions) {
                if (versions.isEmpty && configId != null) {
                  return const Center(
                    child: Text('No history found for this item.'),
                  );
                }

                if (configId == null) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.history,
                          size: 48,
                          color: AppTheme.textTertiary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Select a configuration from the list to see its history.',
                        ),
                      ],
                    ),
                  );
                }

                return SmartTable<ConfigVersion>(
                  columns: const ['Version', 'Value', 'User', 'Date', ''],
                  data: versions,
                  rowBuilder: (item) => [
                    Text(
                      item.version,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 8,
                          backgroundColor: AppTheme.textTertiary,
                          child: Icon(
                            Icons.person,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.createdBy ?? 'System',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat('MMM d, HH:mm').format(item.createdAt),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('Restore'),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
