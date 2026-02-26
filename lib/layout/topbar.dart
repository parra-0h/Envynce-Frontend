import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class Topbar extends StatelessWidget implements PreferredSizeWidget {
  const Topbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Mobile menu trigger would go here
          if (MediaQuery.of(context).size.width <= 800)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: const Icon(
                  LucideIcons.menu,
                  color: AppTheme.textSecondary,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),

          Expanded(child: _buildBreadcrumbs()),

          const SizedBox(width: 16),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              LucideIcons.bell,
              size: 20,
              color: AppTheme.textSecondary,
            ),
            splashRadius: 20,
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              LucideIcons.helpCircle,
              size: 20,
              color: AppTheme.textSecondary,
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    return Row(
      children: [
        const Icon(LucideIcons.home, size: 16, color: AppTheme.textTertiary),
        const SizedBox(width: 8),
        const Text('/', style: TextStyle(color: AppTheme.textTertiary)),
        const SizedBox(width: 8),
        Text(
          'Project',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        const Text('/', style: TextStyle(color: AppTheme.textTertiary)),
        const SizedBox(width: 8),
        Text(
          'Config Service',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
