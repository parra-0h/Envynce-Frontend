import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../widgets/app_card.dart';
import '../widgets/status_badge.dart';

class _Environment {
  final String name;
  final String description;
  final String status;
  final int activeConfigs;
  final String version;
  final Color color;

  _Environment(
    this.name,
    this.description,
    this.status,
    this.activeConfigs,
    this.version,
    this.color,
  );
}

class EnvironmentsView extends StatelessWidget {
  const EnvironmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_Environment> envs = [
      _Environment(
        'Production',
        'Live environment serving end users.',
        'Active',
        142,
        'v2.4.0',
        Colors.purple,
      ),
      _Environment(
        'Staging',
        'Pre-production testing environment.',
        'Active',
        138,
        'v2.4.0-rc1',
        Colors.orange,
      ),
      _Environment(
        'Development',
        'Internal development sandbox.',
        'Active',
        156,
        'v2.5.0-dev',
        Colors.blue,
      ),
      _Environment(
        'Disaster Recovery',
        'Fallback environment for emergencies.',
        'Inactive',
        142,
        'v2.3.5',
        Colors.red,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          PageHeader(
            title: 'Environments',
            description:
                'Manage deployment environments and their specific settings.',
            actions: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Add Environment'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
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
                return _buildEnvironmentCard(env);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentCard(_Environment env) {
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
                  color: env.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.server, color: env.color, size: 24),
              ),
              StatusBadge(
                label: env.status,
                type: env.status == 'Active'
                    ? StatusType.success
                    : StatusType.neutral,
              ),
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
          Text(
            env.description,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Configs', env.activeConfigs.toString()),
              _buildStat('Version', env.version),
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
}
