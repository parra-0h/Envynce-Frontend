import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../layout/main_layout.dart';
import '../views/dashboard_view.dart';
import '../views/applications_view.dart';
import '../views/environments_view.dart';
import '../views/configurations_view.dart';
import '../views/version_history_view.dart';
import '../views/api_keys_view.dart';
import '../views/audit_logs_view.dart';
import '../views/login_view.dart';
import '../providers/auth_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: _AuthRefreshListenable(ref),
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isAuthenticated = authState.isAuthenticated;

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardView(),
          ),
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
});

// A listenable to refresh the router when auth state changes
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this.ref) {
    ref.listen(authProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref ref;
}
