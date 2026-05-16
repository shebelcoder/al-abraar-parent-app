import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class ChildrenScreen extends ConsumerWidget {
  const ChildrenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Children')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _mockChildren.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _ChildCard(child: _mockChildren[i]),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ChildData child;
  const _ChildCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/child/${child.id}', extra: child),
      child: Container(
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  child.name[0],
                  style: const TextStyle(
                    fontSize: 22,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 2),
                  Text(child.grade,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Text('Teacher: ${child.teacher}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.primaryGreen)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Badge(
                          label: 'Surah: ${child.surahProgress}',
                          color: AppTheme.goldAccent),
                      const SizedBox(width: 8),
                      _Badge(
                          label: 'Avg: ${child.averageMark}%',
                          color: child.averageMark >= 85
                              ? AppTheme.successGreen
                              : AppTheme.warningOrange),
                    ],
                  ),
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
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: child.attendanceRate >= 85
                        ? AppTheme.successGreen
                        : AppTheme.warningOrange,
                  ),
                ),
                const Text('Attendance',
                    style: TextStyle(
                        fontSize: 10, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textSecondary, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
