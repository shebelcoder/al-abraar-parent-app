import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../child/child_detail_screen.dart';

const _mockChildren = [
  ChildData(
    id: '1',
    name: 'Abdullah Al-Farsi',
    grade: 'Level 2 — Quran',
    teacher: 'Sheikh Ahmed',
    attendanceRate: 92,
    surahProgress: 'Al-Mulk',
    averageMark: 87,
  ),
  ChildData(
    id: '2',
    name: 'Aisha Al-Farsi',
    grade: 'Level 1 — Quran',
    teacher: 'Ustadha Fatima',
    attendanceRate: 96,
    surahProgress: 'Al-Fatiha',
    averageMark: 91,
  ),
];

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    final user = authAsync.valueOrNull?.user;
    final name = (user?['name'] as String? ?? 'Parent').split(' ').first;

    return Scaffold(
      backgroundColor: AppTheme.warmBackground,
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: AppTheme.surfaceWhite,
              elevation: 0,
              titleSpacing: 16,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'السلام عليكم',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_outlined,
                            color: AppTheme.textDark),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.errorRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () => context.push('/home/notifications'),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'P',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _StatsRow(childCount: _mockChildren.length),
                  const SizedBox(height: 20),
                  const Text(
                    'My Children',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._mockChildren.map((c) => _ChildCard(child: c)),
                  const SizedBox(height: 20),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _QuickActionsGrid(),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int childCount;
  const _StatsRow({required this.childCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, Color(0xFF14532D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
              icon: Icons.child_care_rounded,
              label: 'Children',
              value: '$childCount'),
          _vDivider(),
          const _StatItem(
              icon: Icons.message_rounded,
              label: 'Messages',
              value: '3'),
          _vDivider(),
          const _StatItem(
              icon: Icons.notifications_rounded,
              label: 'Alerts',
              value: '3'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatItem(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }
}

Widget _vDivider() =>
    Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2));

class _ChildCard extends StatelessWidget {
  final ChildData child;
  const _ChildCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/child/${child.id}', extra: child),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  child.name[0],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(child.name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 2),
                  Text(child.grade,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Text('Surah: ${child.surahProgress}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.primaryGreen)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${child.attendanceRate}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: child.attendanceRate >= 85
                        ? AppTheme.successGreen
                        : AppTheme.warningOrange,
                  ),
                ),
                const Text('Attendance',
                    style: TextStyle(
                        fontSize: 10, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textSecondary, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
          icon: Icons.child_care_rounded,
          label: 'Children',
          color: AppTheme.primaryGreen,
          onTap: () => context.go('/home/children')),
      _ActionItem(
          icon: Icons.calendar_today_rounded,
          label: 'Schedule',
          color: const Color(0xFF0EA5E9),
          onTap: () => context.go('/home/schedule')),
      _ActionItem(
          icon: Icons.receipt_long_rounded,
          label: 'Fees',
          color: AppTheme.warningOrange,
          onTap: () => context.go('/home/fees')),
      _ActionItem(
          icon: Icons.grade_rounded,
          label: 'Marks',
          color: const Color(0xFF8B5CF6),
          onTap: () => context.go('/home/children')),
      _ActionItem(
          icon: Icons.message_rounded,
          label: 'Messages',
          color: const Color(0xFF6366F1),
          onTap: () => context.go('/home/messages')),
      _ActionItem(
          icon: Icons.campaign_rounded,
          label: 'Notices',
          color: AppTheme.goldAccent,
          onTap: () => context.push('/home/notifications')),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) {
        final a = actions[i];
        return GestureDetector(
          onTap: a.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: a.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(a.icon, color: a.color, size: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  a.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionItem(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
}
