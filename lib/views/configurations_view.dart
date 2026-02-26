import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/configuration_model.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../widgets/smart_table.dart';
import '../widgets/status_badge.dart';
import '../widgets/configuration_modal.dart';
import '../providers/config_provider.dart';

class ConfigurationsView extends ConsumerStatefulWidget {
  const ConfigurationsView({super.key});

  @override
  ConsumerState<ConfigurationsView> createState() => _ConfigurationsViewState();
}

class _ConfigurationsViewState extends ConsumerState<ConfigurationsView> {
  String _searchQuery = '';
  String? _selectedEnvironment;

  @override
  Widget build(BuildContext context) {
    // For now, using hardcoded IDs to verify connection
    // In a real app, these would come from the selected app/env in the sidebar/topbar
    final configsAsync = ref.watch(
      configurationsProvider(const {'application_id': 1, 'environment_id': 1}),
    );

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Configurations',
            description:
                'Manage your application settings across environments.',
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ConfigurationModal(),
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
                final filteredItems = items.where((item) {
                  final matchesSearch =
                      item.key.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      item.value.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                  final matchesEnv =
                      _selectedEnvironment == null ||
                      item.environment == _selectedEnvironment;
                  return matchesSearch && matchesEnv;
                }).toList();

                return SmartTable<ConfigurationItem>(
                  columns: const [
                    'Key',
                    'Value',
                    'Environment',
                    'Version',
                    'Last Updated',
                    'Status',
                    '',
                  ],
                  data: filteredItems,
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
                    _buildEnvironmentBadge(item.environment),
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
                        PopupMenuButton(
                          icon: const Icon(
                            LucideIcons.moreHorizontal,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    ConfigurationModal(item: item),
                              );
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
                        configurationsProvider(const {
                          'application_id': 1,
                          'environment_id': 1,
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
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.borderColor),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedEnvironment,
              hint: const Text('All Environments'),
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              icon: const Icon(
                LucideIcons.chevronDown,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              items: [
                'Production',
                'Staging',
                'Development',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) =>
                  setState(() => _selectedEnvironment = value),
            ),
          ),
        ),
        if (_selectedEnvironment != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(LucideIcons.x, size: 16),
            onPressed: () => setState(() => _selectedEnvironment = null),
            tooltip: 'Clear Environment Filter',
          ),
        ],
      ],
    );
  }

  Widget _buildEnvironmentBadge(String environment) {
    Color color;
    switch (environment.toLowerCase()) {
      case 'production':
      case '1': // Using ID for now as fallback
        color = Colors.purple;
        break;
      case 'staging':
      case '2':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        environment == '1'
            ? 'Production'
            : (environment == '2' ? 'Staging' : environment),
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
