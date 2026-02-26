import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layout/main_layout.dart';
import '../views/dashboard_view.dart';
import '../views/applications_view.dart';
import '../views/environments_view.dart';
import '../views/configurations_view.dart';
import '../views/version_history_view.dart';
import '../views/api_keys_view.dart';
import '../views/audit_logs_view.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const DashboardView()),
        GoRoute(
          path: '/applications',
          builder: (context, state) => const ApplicationsView(),
        ),
        GoRoute(
          path: '/environments',
          builder: (context, state) => const EnvironmentsView(),
        ),
        GoRoute(
          path: '/configurations',
          builder: (context, state) => const ConfigurationsView(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const VersionHistoryView(),
        ),
        GoRoute(
          path: '/api-keys',
          builder: (context, state) => const ApiKeysView(),
        ),
        GoRoute(
          path: '/logs',
          builder: (context, state) => const AuditLogsView(),
        ),
      ],
    ),
  ],
);
