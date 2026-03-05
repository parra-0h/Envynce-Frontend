import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppTheme.secondaryColor,
        border: Border(right: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Column(
        children: [
          _buildLogo(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    'MAIN MENU',
                    style: TextStyle(
                      color: Color(0xFF97A0AF),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                _SidebarItem(
                  icon: LucideIcons.layoutDashboard,
                  label: 'Dashboard',
                  route: '/',
                ),
                _SidebarItem(
                  icon: LucideIcons.layers,
                  label: 'Applications',
                  route: '/applications',
                ),
                _SidebarItem(
                  icon: LucideIcons.server,
                  label: 'Environments',
                  route: '/environments',
                ),
                _SidebarItem(
                  icon: LucideIcons.settings,
                  label: 'Configurations',
                  route: '/configurations',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    'SYSTEM',
                    style: TextStyle(
                      color: Color(0xFF97A0AF),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                _SidebarItem(
                  icon: LucideIcons.history,
                  label: 'Version History',
                  route: '/history',
                ),
                _SidebarItem(
                  icon: LucideIcons.key,
                  label: 'API Keys',
                  route: '/api-keys',
                ),
                _SidebarItem(
                  icon: LucideIcons.fileText,
                  label: 'Audit Logs',
                  route: '/logs',
                ),
                if (user?.isAdmin ?? false)
                  _SidebarItem(
                    icon: LucideIcons.users,
                    label: 'User Management',
                    route: '/users',
                  ),
              ],
            ),
          ),
          const Spacer(),
          if (user != null) _buildUserSection(context, ref, user),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 64,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF253858))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(LucideIcons.zap, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Envynce',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSection(BuildContext context, WidgetRef ref, dynamic user) {
    final nameInitial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF253858))),
      ),
      child: InkWell(
        onTap: () => context.go('/profile'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                radius: 18,
                child: Text(
                  nameInitial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.role.toString().split('.').last.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => ref.read(authProvider.notifier).logout(),
                icon: Icon(
                  LucideIcons.logOut,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                tooltip: 'Logout',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final String currentLocation = GoRouterState.of(context).uri.toString();
    // Check if the current location starts with the route to handle nested routes or parameters
    // But for this simple app, we'll use exact match or sub-path check
    final bool isActive =
        currentLocation == route ||
        (route != '/' && currentLocation.startsWith(route));

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isActive ? AppTheme.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(6),
          hoverColor: Colors.white.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.7),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
