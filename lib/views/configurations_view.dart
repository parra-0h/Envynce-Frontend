import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/configuration_model.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../widgets/smart_table.dart';
import '../widgets/status_badge.dart';
import '../widgets/configuration_modal.dart';
import '../providers/config_provider.dart';
import '../providers/auth_provider.dart';

class ConfigurationsView extends ConsumerStatefulWidget {
  const ConfigurationsView({super.key});

  @override
  ConsumerState<ConfigurationsView> createState() => _ConfigurationsViewState();
}

class _ConfigurationsViewState extends ConsumerState<ConfigurationsView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final selectedApp = ref.watch(selectedApplicationProvider);
    final selectedEnv = ref.watch(selectedEnvironmentProvider);
    final user = ref.watch(authProvider).user;
    final canEdit = user?.canEdit ?? false;

    if (selectedApp == null || selectedEnv == null) {
      return _buildSelectionPlaceholder();
    }

    final configsAsync = ref.watch(
      configurationsProvider({
        'application_id': selectedApp.id,
        'environment_id': selectedEnv.id,
        'search': _searchQuery.isEmpty ? null : _searchQuery,
      }),
    );

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Configurations',
            description:
                'Manage settings for ${selectedApp.name} in ${selectedEnv.name}.',
            actions: [
              if (canEdit)
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfigurationModal(
                        applicationId: selectedApp.id,
                        environmentId: selectedEnv.id,
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Add Configuration'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(
            child: configsAsync.when(
              data: (items) {
                return SmartTable<ConfigurationItem>(
                  columns: const [
                    'Key',
                    'Value',
                    'Version',
                    'Last Updated',
                    'Status',
                    '',
                  ],
                  data: items,
                  rowBuilder: (item) => [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.fileCode,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.version,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    Text(
                      DateFormat('MMM d, h:mm a').format(item.lastUpdated),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    StatusBadge(
                      label: item.isActive ? 'Active' : 'Inactive',
                      type: item.isActive
                          ? StatusType.success
                          : StatusType.neutral,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        PopupMenuButton<String>(
                          icon: const Icon(
                            LucideIcons.moreHorizontal,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              showDialog(
                                context: context,
                                builder: (context) => ConfigurationModal(
                                  applicationId: selectedApp.id,
                                  environmentId: selectedEnv.id,
                                  item: item,
                                ),
                              );
                            } else if (value == 'history') {
                              context.push(
                                '/history?id=${item.id}&key=${item.key}',
                              );
                            } else if (value == 'delete') {
                              _confirmDelete(item);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'history',
                              child: Text('History'),
                            ),
                            if (canEdit)
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.alertCircle,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text('Error loading configurations: $err'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(
                        configurationsProvider({
                          'application_id': selectedApp.id,
                          'environment_id': selectedEnv.id,
                        }),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(ConfigurationItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${item.key}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(deleteConfigurationProvider(item.id).future);
    }
  }

  Widget _buildSelectionPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.info, size: 64, color: AppTheme.textTertiary),
          const SizedBox(height: 24),
          const Text(
            'Select an application and environment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'You must first choose an application and environment to view configurations.',
            style: TextStyle(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            children: [
              ElevatedButton(
                onPressed: () => context.go('/applications'),
                child: const Text('Go to Applications'),
              ),
              ElevatedButton(
                onPressed: () => context.go('/environments'),
                child: const Text('Go to Environments'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        SizedBox(
          width: 320,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search keys or values...',
              prefixIcon: Icon(
                LucideIcons.search,
                size: 20,
                color: AppTheme.textSecondary,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
      ],
    );
  }
}
