import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../widgets/smart_table.dart';
import '../widgets/status_badge.dart';
import '../providers/config_provider.dart';
import '../providers/auth_provider.dart';
import '../models/app_model.dart';

class ApplicationsView extends ConsumerWidget {
  const ApplicationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(applicationsProvider);
    final user = ref.watch(authProvider).user;
    final canEdit = user?.canEdit ?? false;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          PageHeader(
            title: 'Applications',
            description: 'Manage registered applications and their access.',
            actions: [
              if (canEdit)
                ElevatedButton.icon(
                  onPressed: () => _showNewAppDialog(context, ref),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('New Application'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: appsAsync.when(
              data: (apps) {
                return SmartTable<Application>(
                  columns: const ['Name', 'ID', 'Status', 'Description', ''],
                  data: apps,
                  rowBuilder: (app) => [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
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
                    const StatusBadge(
                      label: 'Active',
                      type: StatusType.success,
                    ),
                    Text(
                      app.description ?? '',
                      style: const TextStyle(color: AppTheme.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            ref
                                .read(selectedApplicationProvider.notifier)
                                .set(app);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Selected ${app.name}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Text('Select'),
                        ),
                        if (canEdit)
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

  void _showNewAppDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await ref.read(
                  createApplicationProvider({
                    'name': nameController.text,
                    'description': descController.text,
                  }).future,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
