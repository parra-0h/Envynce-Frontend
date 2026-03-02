import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../widgets/app_card.dart';
import '../widgets/status_badge.dart';
import '../providers/config_provider.dart';
import '../providers/auth_provider.dart';
import '../models/app_model.dart';

class EnvironmentsView extends ConsumerWidget {
  const EnvironmentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final envsAsync = ref.watch(environmentsProvider);
    final user = ref.watch(authProvider).user;
    final canEdit = user?.canEdit ?? false;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          PageHeader(
            title: 'Environments',
            description:
                'Manage deployment environments and their specific settings.',
            actions: [
              if (canEdit)
                ElevatedButton.icon(
                  onPressed: () => _showNewEnvDialog(context, ref),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Add Environment'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: envsAsync.when(
              data: (envs) {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 1200
                        ? 3
                        : (MediaQuery.of(context).size.width > 800 ? 2 : 1),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 220,
                  ),
                  itemCount: envs.length,
                  itemBuilder: (context, index) {
                    final env = envs[index];
                    return _buildEnvironmentCard(context, ref, env, canEdit);
                  },
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

  Widget _buildEnvironmentCard(
    BuildContext context,
    WidgetRef ref,
    Environment env,
    bool canEdit,
  ) {
    final selectedEnv = ref.watch(selectedEnvironmentProvider);
    final isSelected = selectedEnv?.id == env.id;

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _parseColor(env.color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  LucideIcons.server,
                  color: _parseColor(env.color),
                  size: 24,
                ),
              ),
              const StatusBadge(label: 'Active', type: StatusType.success),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            env.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Environment for configuration targeting.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('ID', env.id),
              ElevatedButton(
                onPressed: () {
                  ref.read(selectedEnvironmentProvider.notifier).set(env);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected ${env.name}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                style: isSelected
                    ? ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      )
                    : null,
                child: Text(isSelected ? 'Selected' : 'Select'),
              ),
              if (canEdit)
                IconButton(
                  icon: const Icon(
                    LucideIcons.settings,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () {},
                  tooltip: 'Settings',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorStr) {
    try {
      if (colorStr.startsWith('#')) {
        return Color(int.parse(colorStr.substring(1), radix: 16) + 0xFF000000);
      }
    } catch (_) {}
    return AppTheme.primaryColor;
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showNewEnvDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Environment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
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
                // Assuming createEnvironmentProvider still works with simple Map
                // but usually we'd have a specific model or mutation
                final api = ref.read(apiServiceProvider);
                await api.post('/environments', {'name': nameController.text});
                ref.invalidate(environmentsProvider);
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
