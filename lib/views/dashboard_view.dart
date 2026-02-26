import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../widgets/metric_card.dart';
import '../widgets/app_card.dart';
import 'components/activity_chart.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
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
          _buildMetricsGrid(context),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 2, child: ActivityChart()),
              if (MediaQuery.of(context).size.width > 1200) ...[
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildRecentActivityList()),
              ],
            ],
          ),
          if (MediaQuery.of(context).size.width <= 1200) ...[
            const SizedBox(height: 24),
            _buildRecentActivityList(),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    // Responsive grid
    double width = MediaQuery.of(context).size.width;
    int crossAxisCount = width > 1400 ? 4 : (width > 1000 ? 2 : 1);

    // Manual grid for better control or use Wrap/GridView
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: (width - 48 - (16 * (crossAxisCount - 1))) / crossAxisCount,
          child: const MetricCard(
            label: 'Total Requests',
            value: '2.4M',
            icon: LucideIcons.activity,
            trend: '12%',
            isTrendPositive: true,
          ),
        ),
        SizedBox(
          width: (width - 48 - (16 * (crossAxisCount - 1))) / crossAxisCount,
          child: const MetricCard(
            label: 'Active Configurations',
            value: '142',
            icon: LucideIcons.settings,
            trend: '4%',
            isTrendPositive: true,
          ),
        ),
        SizedBox(
          width: (width - 48 - (16 * (crossAxisCount - 1))) / crossAxisCount,
          child: const MetricCard(
            label: 'Registered Apps',
            value: '12',
            icon: LucideIcons.layers,
            trend: '0%',
            isTrendPositive: true, // Neutral
          ),
        ),
        SizedBox(
          width: (width - 48 - (16 * (crossAxisCount - 1))) / crossAxisCount,
          child: const MetricCard(
            label: 'Error Rate',
            value: '0.05%',
            icon: LucideIcons.alertCircle,
            trend: '0.01%',
            isTrendPositive:
                false, // Negative trend is good for errors usually, but here green means good.
            // Let's assume widget takes isTrendPositive as "Visual Green".
            // If error rate went DOWN, it is good (Green).
            // If error rate went UP, it is bad (Red).
            // Let's say it went DOWN.
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityList() {
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _getActivityIcon(index),
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
                              const TextSpan(text: 'Updated config '),
                              TextSpan(
                                text: 'feature_flags.${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '2 minutes ago by admin@company.com',
                          style: TextStyle(
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

  Widget _getActivityIcon(int index) {
    if (index % 3 == 0) {
      return const Icon(
        LucideIcons.edit3,
        size: 16,
        color: AppTheme.primaryColor,
      );
    } else if (index % 3 == 1) {
      return const Icon(
        LucideIcons.plus,
        size: 16,
        color: AppTheme.successColor,
      );
    } else {
      return const Icon(
        LucideIcons.trash2,
        size: 16,
        color: AppTheme.errorColor,
      );
    }
  }
}
