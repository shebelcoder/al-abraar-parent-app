import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedChild = 0;
  int _selectedDay = DateTime.now().weekday - 1;

  static const _children = ['Abdullah', 'Aisha'];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static const _schedules = [
    // Abdullah's schedule
    {
      0: [
        _Session('9:00 AM', 'Quran Recitation', 'Sheikh Ahmed', '45 min', 'Completed'),
        _Session('4:00 PM', 'Arabic Language', 'Ustadh Ali', '30 min', 'Upcoming'),
      ],
      1: [
        _Session('10:00 AM', 'Tajweed Rules', 'Sheikh Ahmed', '60 min', 'Upcoming'),
      ],
      2: [
        _Session('9:00 AM', 'Quran Memorisation', 'Ustadha Fatima', '45 min', 'Completed'),
        _Session('3:00 PM', 'Islamic Studies', 'Ustadh Omar', '30 min', 'Upcoming'),
      ],
      3: [
        _Session('4:30 PM', 'Quran Recitation', 'Sheikh Ahmed', '45 min', 'Upcoming'),
      ],
      4: [
        _Session('11:00 AM', 'Arabic Vocabulary', 'Ustadh Ali', '30 min', 'Upcoming'),
      ],
    },
    // Aisha's schedule
    {
      0: [
        _Session('10:00 AM', 'Quran Recitation', 'Ustadha Fatima', '30 min', 'Completed'),
      ],
      1: [
        _Session('9:30 AM', 'Quran Memorisation', 'Ustadha Fatima', '45 min', 'Upcoming'),
        _Session('3:00 PM', 'Islamic Studies', 'Ustadh Omar', '30 min', 'Upcoming'),
      ],
      3: [
        _Session('10:00 AM', 'Arabic Language', 'Ustadh Ali', '30 min', 'Upcoming'),
      ],
      4: [
        _Session('4:00 PM', 'Quran Recitation', 'Ustadha Fatima', '30 min', 'Upcoming'),
      ],
    },
  ];

  List<_Session> get _sessions =>
      (_schedules[_selectedChild][_selectedDay] ?? []).cast<_Session>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmBackground,
      appBar: AppBar(
        title: const Text('Schedule'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Child selector
          Container(
            color: AppTheme.surfaceWhite,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: List.generate(_children.length, (i) {
                final selected = i == _selectedChild;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedChild = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: i < _children.length - 1 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.primaryGreen : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _children[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: selected ? Colors.white : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Day selector
          Container(
            color: AppTheme.surfaceWhite,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: List.generate(_days.length, (i) {
                  final selected = i == _selectedDay;
                  final isToday = i == DateTime.now().weekday - 1;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.primaryGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppTheme.primaryGreen
                              : isToday
                                  ? AppTheme.primaryGreen.withValues(alpha: 0.4)
                                  : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _days[i],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: selected ? Colors.white : AppTheme.textSecondary,
                            ),
                          ),
                          if (isToday)
                            Container(
                              margin: const EdgeInsets.only(top: 3),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: selected ? Colors.white : AppTheme.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Sessions
          Expanded(
            child: _sessions.isEmpty
                ? _EmptyDay(childName: _children[_selectedChild])
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _SessionCard(session: _sessions[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final _Session session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final isDone = session.status == 'Completed';
    return Container(
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
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: (isDone ? AppTheme.textSecondary : AppTheme.primaryGreen)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  session.time.split(' ')[0],
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: isDone ? AppTheme.textSecondary : AppTheme.primaryGreen,
                  ),
                ),
                Text(
                  session.time.split(' ')[1],
                  style: TextStyle(
                    fontSize: 11,
                    color: isDone ? AppTheme.textSecondary : AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.subject,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDone ? AppTheme.textSecondary : AppTheme.textDark,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 13, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(session.teacher,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(width: 10),
                    const Icon(Icons.timer_outlined,
                        size: 13, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(session.duration,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFFF3F4F6)
                  : AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              session.status,
              style: TextStyle(
                color: isDone ? AppTheme.textSecondary : AppTheme.primaryGreen,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  final String childName;
  const _EmptyDay({required this.childName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_available_rounded,
                size: 40, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 16),
          Text(
            'No classes for $childName',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No sessions scheduled for this day.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Session {
  final String time;
  final String subject;
  final String teacher;
  final String duration;
  final String status;
  const _Session(
      this.time, this.subject, this.teacher, this.duration, this.status);
}
