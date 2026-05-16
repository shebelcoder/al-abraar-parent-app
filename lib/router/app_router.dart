import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/dashboard_screen.dart';
import '../screens/home/children_screen.dart';
import '../screens/home/messages_screen.dart';
import '../screens/home/profile_screen.dart';
import '../screens/home/notifications_screen.dart';
import '../screens/child/child_detail_screen.dart';
import '../widgets/main_shell.dart';

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<AuthState>>(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authAsync = _ref.read(authStateProvider);
    if (authAsync.isLoading) return null;

    final isLoggedIn = authAsync.valueOrNull?.isLoggedIn ?? false;
    final path = state.uri.path;
    final isAuthRoute = path == '/login' || path == '/splash';

    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && (path == '/login' || path == '/splash')) {
      return '/home/dashboard';
    }
    return null;
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      // Notifications pushed on top of shell
      GoRoute(
        path: '/home/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      // Child detail pushed on top of shell
      GoRoute(
        path: '/home/child/:id',
        builder: (_, state) {
          final child = state.extra as ChildData?;
          if (child == null) return const _NotFoundScreen();
          return ChildDetailScreen(child: child);
        },
      ),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/home/children',
            builder: (_, __) => const ChildrenScreen(),
          ),
          GoRoute(
            path: '/home/messages',
            builder: (_, __) => const MessagesScreen(),
          ),
          GoRoute(
            path: '/home/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: const Center(child: Text('Page not found')),
    );
  }
}
