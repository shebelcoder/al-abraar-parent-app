import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path.startsWith('/home/children')) return 1;
    if (path.startsWith('/home/schedule')) return 2;
    if (path.startsWith('/home/messages')) return 3;
    if (path.startsWith('/home/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        indicatorColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/home/dashboard');
            case 1:
              context.go('/home/children');
            case 2:
              context.go('/home/schedule');
            case 3:
              context.go('/home/messages');
            case 4:
              context.go('/home/profile');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded,
                color: AppTheme.primaryGreen),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.child_care_outlined),
            selectedIcon: Icon(Icons.child_care_rounded,
                color: AppTheme.primaryGreen),
            label: 'Children',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded,
                color: AppTheme.primaryGreen),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.message_outlined),
            selectedIcon:
                Icon(Icons.message_rounded, color: AppTheme.primaryGreen),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon:
                Icon(Icons.person_rounded, color: AppTheme.primaryGreen),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
