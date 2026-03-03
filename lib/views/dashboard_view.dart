import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../widgets/metric_card.dart';
import '../widgets/app_card.dart';
import '../providers/dashboard_provider.dart';
import 'components/activity_chart.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Dashboard',
            description: 'Overview of your system activity and health.',
          ),
          const SizedBox(height: 24),
          statsAsync.when(
            data: (stats) => Column(
              children: [
                _buildMetricsGrid(context, stats),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(flex: 2, child: ActivityChart()),
                    if (MediaQuery.of(context).size.width > 1200) ...[
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: _buildRecentActivityList(stats.updates),
                      ),
                    ],
                  ],
                ),
                if (MediaQuery.of(context).size.width <= 1200) ...[
                  const SizedBox(height: 24),
                  _buildRecentActivityList(stats.updates),
                ],
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, DashboardStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : (constraints.maxWidth > 700 ? 2 : 1);
        double spacing = 16;
        double itemWidth =
            (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
            crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: MetricCard(
                label: 'Registered Apps',
                value: stats.totalApps.toString(),
                icon: LucideIcons.layers,
                trend: 'Directly from API',
                isTrendPositive: true,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: MetricCard(
                label: 'Total Configurations',
                value: stats.totalConfigs.toString(),
                icon: LucideIcons.settings,
                trend: 'Across all envs',
                isTrendPositive: true,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: MetricCard(
                label: 'Active Configs',
                value: stats.activeConfigs.toString(),
                icon: LucideIcons.zap,
                trend: 'Currently serving',
                isTrendPositive: true,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: MetricCard(
                label: 'Environments',
                value: stats.totalEnvironments.toString(),
                icon: LucideIcons.server,
                trend: 'Active stages',
                isTrendPositive: true,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivityList(List<dynamic> updates) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 16),
          if (updates.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No recent activity found',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: updates.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final update = updates[index];
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.edit3,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                              ),
                              children: [
                                const TextSpan(text: 'Updated '),
                                TextSpan(
                                  text: update['key'] ?? 'unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${update['user_name'] ?? 'User'} - ${update['created_at'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
