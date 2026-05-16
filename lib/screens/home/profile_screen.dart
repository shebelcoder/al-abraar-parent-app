import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull?.user;
    final name = user?['name'] as String? ?? 'Parent';
    final email = user?['email'] as String? ?? '';
    final initials = name.isNotEmpty
        ? name.split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'P';

    return Scaffold(
      backgroundColor: AppTheme.warmBackground,
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          // Header
          Container(
            color: AppTheme.surfaceWhite,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Parent',
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(label: 'Children', value: '2', icon: '👶'),
                    _vDivider(),
                    _StatItem(label: 'Messages', value: '3', icon: '💬'),
                    _vDivider(),
                    _StatItem(label: 'Alerts', value: '3', icon: '🔔'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _MenuSection(
            title: 'Children',
            items: [
              _MenuItem(
                icon: Icons.child_care_rounded,
                label: 'My Children',
                color: AppTheme.primaryGreen,
                onTap: () => context.go('/home/children'),
              ),
              _MenuItem(
                icon: Icons.calendar_today_rounded,
                label: 'Schedule',
                color: const Color(0xFF0EA5E9),
                onTap: () => context.go('/home/schedule'),
              ),
              _MenuItem(
                icon: Icons.receipt_long_rounded,
                label: 'Fees',
                color: AppTheme.warningOrange,
                onTap: () => context.go('/home/fees'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MenuSection(
            title: 'Academic',
            items: [
              _MenuItem(
                icon: Icons.how_to_reg_rounded,
                label: 'Attendance',
                color: const Color(0xFF0EA5E9),
                onTap: () => context.go('/home/children'),
              ),
              _MenuItem(
                icon: Icons.grade_rounded,
                label: 'Marks',
                color: const Color(0xFF8B5CF6),
                onTap: () => context.go('/home/children'),
              ),
              _MenuItem(
                icon: Icons.article_rounded,
                label: 'Report Cards',
                color: AppTheme.successGreen,
                onTap: () => context.go('/home/children'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MenuSection(
            title: 'Account',
            items: [
              _MenuItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                color: AppTheme.goldAccent,
                onTap: () => context.push('/home/notifications'),
              ),
              _MenuItem(
                icon: Icons.logout_rounded,
                label: 'Logout',
                color: AppTheme.errorRed,
                isDestructive: true,
                onTap: () => _confirmLogout(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout',
                style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
      if (context.mounted) context.go('/login');
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  const _StatItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark)),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

Widget _vDivider() =>
    Container(width: 1, height: 40, color: const Color(0xFFE5E7EB));

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          color: AppTheme.surfaceWhite,
          child: Column(
            children: items.asMap().entries.map((e) {
              return Column(
                children: [
                  e.value,
                  if (e.key < items.length - 1)
                    const Divider(
                        height: 1, indent: 56, color: Color(0xFFF3F4F6)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDestructive;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppTheme.errorRed : AppTheme.textDark,
        ),
      ),
      trailing: isDestructive
          ? null
          : const Icon(Icons.chevron_right_rounded,
              color: AppTheme.textSecondary),
    );
  }
}
