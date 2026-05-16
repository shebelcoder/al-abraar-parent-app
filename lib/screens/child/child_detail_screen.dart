import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../services/stripe_service.dart';
import '../../theme/app_theme.dart';

// ────────────────────────────────────────────────────────────────────────────
// Data model (passed via router extra)
// ────────────────────────────────────────────────────────────────────────────

class ChildData {
  final String id;
  final String name;
  final String grade;
  final String teacher;
  final int attendanceRate;
  final String surahProgress;
  final int averageMark;

  const ChildData({
    required this.id,
    required this.name,
    required this.grade,
    required this.teacher,
    required this.attendanceRate,
    required this.surahProgress,
    required this.averageMark,
  });
}

// ────────────────────────────────────────────────────────────────────────────
// Screen
// ────────────────────────────────────────────────────────────────────────────

class ChildDetailScreen extends StatefulWidget {
  final ChildData child;
  const ChildDetailScreen({super.key, required this.child});

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    return Scaffold(
      backgroundColor: AppTheme.warmBackground,
      appBar: AppBar(
        title: Text(child.name.split(' ').first),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryGreen,
          tabs: const [
            Tab(text: 'Attendance'),
            Tab(text: 'Marks'),
            Tab(text: 'Report Card'),
            Tab(text: 'Fees'),
            Tab(text: 'Quran'),
          ],
        ),
      ),
      body: Column(
        children: [
          _ChildHeader(child: child),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _AttendanceTab(rate: child.attendanceRate),
                _MarksTab(averageMark: child.averageMark),
                _ReportCardTab(child: child),
                _FeesTab(childName: child.name.split(' ').first),
                _QuranTab(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Header
// ────────────────────────────────────────────────────────────────────────────

class _ChildHeader extends StatelessWidget {
  final ChildData child;
  const _ChildHeader({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceWhite,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.12),
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
                const SizedBox(height: 2),
                Text('Teacher: ${child.teacher}',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.primaryGreen)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${child.attendanceRate}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: child.attendanceRate >= 85
                        ? AppTheme.successGreen
                        : AppTheme.warningOrange,
                  )),
              const Text('Attendance',
                  style: TextStyle(
                      fontSize: 10, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Attendance Tab
// ────────────────────────────────────────────────────────────────────────────

enum _Att { present, absent, excused, none }

class _AttendanceTab extends StatefulWidget {
  final int rate;
  const _AttendanceTab({required this.rate});

  @override
  State<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<_AttendanceTab> {
  late DateTime _month;

  static final Map<int, _Att> _mockData = {
    1: _Att.present, 2: _Att.present, 3: _Att.absent,
    4: _Att.present, 5: _Att.none, 6: _Att.none,
    7: _Att.present, 8: _Att.present, 9: _Att.present,
    10: _Att.excused, 11: _Att.present, 12: _Att.present,
    13: _Att.absent, 14: _Att.none, 15: _Att.none,
    16: _Att.present, 17: _Att.present, 18: _Att.present,
    19: _Att.present, 20: _Att.present, 21: _Att.none,
    22: _Att.none, 23: _Att.present, 24: _Att.present,
    25: _Att.absent, 26: _Att.present, 27: _Att.present,
    28: _Att.present,
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  int get _present => _mockData.values.where((v) => v == _Att.present).length;
  int get _absent => _mockData.values.where((v) => v == _Att.absent).length;
  int get _excused => _mockData.values.where((v) => v == _Att.excused).length;
  int get _total => _present + _absent + _excused;
  double get _rate => _total == 0 ? 0 : _present / _total;

  bool get _canGoNext {
    final now = DateTime.now();
    return _month.year < now.year ||
        (_month.year == now.year && _month.month < now.month);
  }

  String get _monthLabel {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[_month.month - 1]} ${_month.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                  child: _AttStat(
                      label: 'Present', value: '$_present')),
              _AttDivider(),
              Expanded(
                  child:
                      _AttStat(label: 'Absent', value: '$_absent')),
              _AttDivider(),
              Expanded(
                  child: _AttStat(
                      label: 'Rate',
                      value: '${(_rate * 100).round()}%')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => setState(() =>
                        _month = DateTime(_month.year, _month.month - 1)),
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: AppTheme.textDark),
                  ),
                  Text(_monthLabel,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark)),
                  IconButton(
                    onPressed: _canGoNext
                        ? () => setState(() => _month =
                            DateTime(_month.year, _month.month + 1))
                        : null,
                    icon: Icon(Icons.chevron_right_rounded,
                        color: _canGoNext
                            ? AppTheme.textDark
                            : AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(d,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              _CalendarGrid(month: _month, data: _mockData),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegendItem(label: 'Present', color: AppTheme.successGreen),
              _LegendItem(label: 'Absent', color: AppTheme.errorRed),
              _LegendItem(label: 'Excused', color: AppTheme.goldAccent),
              _LegendItem(label: 'No Class', color: Color(0xFFE5E7EB)),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final Map<int, _Att> data;
  const _CalendarGrid({required this.month, required this.data});

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(month.year, month.month, 1).weekday - 1;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final rows = ((firstWeekday + daysInMonth) / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: List.generate(7, (col) {
              final cell = row * 7 + col;
              final day = cell - firstWeekday + 1;
              if (day < 1 || day > daysInMonth) {
                return const Expanded(child: SizedBox());
              }
              final att = data[day] ?? _Att.none;
              return Expanded(child: _DayCell(day: day, att: att));
            }),
          ),
        );
      }),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final _Att att;
  const _DayCell({required this.day, required this.att});

  Color get _bg {
    switch (att) {
      case _Att.present:
        return AppTheme.successGreen;
      case _Att.absent:
        return AppTheme.errorRed;
      case _Att.excused:
        return AppTheme.goldAccent;
      case _Att.none:
        return const Color(0xFFF3F4F6);
    }
  }

  Color get _fg =>
      att == _Att.none ? AppTheme.textSecondary : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: _bg, shape: BoxShape.circle),
        child: Center(
          child: Text('$day',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: _fg)),
        ),
      ),
    );
  }
}

class _AttStat extends StatelessWidget {
  final String label;
  final String value;
  const _AttStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

class _AttDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1,
        height: 36,
        color: Colors.white.withValues(alpha: 0.3));
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Marks Tab
// ────────────────────────────────────────────────────────────────────────────

class _MarksTab extends StatefulWidget {
  final int averageMark;
  const _MarksTab({required this.averageMark});

  @override
  State<_MarksTab> createState() => _MarksTabState();
}

class _MarksTabState extends State<_MarksTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _assessments = [
    _Assessment('Quran Recitation', 'Al-Mulk Test', '88/100', 88, 'Apr 28'),
    _Assessment('Tajweed Rules', 'Mid-term Quiz', '76/100', 76, 'Apr 22'),
    _Assessment('Arabic Language', 'Vocab Test 3', '91/100', 91, 'Apr 18'),
    _Assessment('Quran Memorisation', 'Juz Amma Progress', '82/100', 82, 'Apr 12'),
    _Assessment('Islamic Studies', 'Unit 2 Exam', '69/100', 69, 'Apr 5'),
    _Assessment('Quran Recitation', 'Surah Yaseen', '94/100', 94, 'Mar 29'),
  ];

  static const _subjects = [
    _Subject('Quran Recitation', 91, 3),
    _Subject('Arabic Language', 82, 2),
    _Subject('Tajweed Rules', 80, 2),
    _Subject('Quran Memorisation', 82, 1),
    _Subject('Islamic Studies', 69, 1),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  double get _average =>
      _assessments.fold(0, (s, a) => s + a.score) / _assessments.length;
  int get _highest =>
      _assessments.map((a) => a.score).reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppTheme.surfaceWhite,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatChip(
                  label: 'Average',
                  value: '${_average.round()}%',
                  color: _gradeColor(_average.round())),
              _vDiv(),
              _StatChip(
                  label: 'Best',
                  value: '$_highest%',
                  color: AppTheme.successGreen),
              _vDiv(),
              _StatChip(
                  label: 'Tests',
                  value: '${_assessments.length}',
                  color: AppTheme.primaryGreen),
            ],
          ),
        ),
        TabBar(
          controller: _tabCtrl,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryGreen,
          tabs: const [Tab(text: 'Recent'), Tab(text: 'By Subject')],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _assessments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) =>
                    _AssessmentCard(a: _assessments[i]),
              ),
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ..._subjects.map((s) => _SubjectCard(s: s)),
                  const SizedBox(height: 80),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  final _Assessment a;
  const _AssessmentCard({required this.a});

  @override
  Widget build(BuildContext context) {
    final color = _gradeColor(a.score);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(_gradeLabel(a.score),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: color)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.subject,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 2),
                Text(a.title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(a.mark,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: color)),
              const SizedBox(height: 2),
              Text(a.date,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final _Subject s;
  const _SubjectCard({required this.s});

  @override
  Widget build(BuildContext context) {
    final color = _gradeColor(s.average);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: s.average / 100,
                    minHeight: 6,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(height: 4),
                Text('${s.tests} test${s.tests == 1 ? '' : 's'}',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Text('${s.average}%',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: color)),
              Text(_gradeLabel(s.average),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

Widget _vDiv() =>
    Container(width: 1, height: 36, color: const Color(0xFFE5E7EB));

Color _gradeColor(int score) {
  if (score >= 85) return AppTheme.successGreen;
  if (score >= 70) return AppTheme.goldAccent;
  return AppTheme.errorRed;
}

String _gradeLabel(int score) {
  if (score >= 90) return 'A';
  if (score >= 80) return 'B';
  if (score >= 70) return 'C';
  if (score >= 60) return 'D';
  return 'F';
}

class _Assessment {
  final String subject;
  final String title;
  final String mark;
  final int score;
  final String date;
  const _Assessment(this.subject, this.title, this.mark, this.score, this.date);
}

class _Subject {
  final String name;
  final int average;
  final int tests;
  const _Subject(this.name, this.average, this.tests);
}

// ────────────────────────────────────────────────────────────────────────────
// Report Card Tab
// ────────────────────────────────────────────────────────────────────────────

class _ReportCardTab extends StatefulWidget {
  final ChildData child;
  const _ReportCardTab({required this.child});

  @override
  State<_ReportCardTab> createState() => _ReportCardTabState();
}

class _ReportCardTabState extends State<_ReportCardTab> {
  int _termIndex = 0;
  static const _terms = ['Term 1', 'Term 2', 'Term 3'];

  static const _termData = [
    _TermData(
      overallGrade: 'B+', overallScore: 83, attendanceRate: 92,
      subjects: [
        _SubjectResult('Quran Recitation', 88, 'A-', 'Sheikh Ahmed',
            'Excellent tajweed. Needs to work on longer surahs.'),
        _SubjectResult('Tajweed Rules', 76, 'C+', 'Sheikh Ahmed',
            'Good understanding of basic rules. Makharij needs more practice.'),
        _SubjectResult('Arabic Language', 91, 'A', 'Ustadh Ali',
            'Outstanding vocabulary. Grammar is a strong point.'),
        _SubjectResult('Quran Memorisation', 82, 'B', 'Ustadha Fatima',
            'Consistent progress. Juz Amma surahs complete.'),
        _SubjectResult('Islamic Studies', 69, 'C', 'Ustadh Omar',
            'Needs to engage more in class discussions.'),
      ],
      comment:
          'A dedicated student this term. Recitation has improved significantly and maintains a positive attitude. Keep up the excellent work!',
      teacher: 'Sheikh Ahmed',
    ),
    _TermData(
      overallGrade: 'A-', overallScore: 87, attendanceRate: 95,
      subjects: [
        _SubjectResult('Quran Recitation', 92, 'A', 'Sheikh Ahmed',
            'Remarkable improvement. Surah Yaseen memorised flawlessly.'),
        _SubjectResult('Tajweed Rules', 84, 'B', 'Sheikh Ahmed',
            'Makharij has improved greatly. Ghunna rules are now solid.'),
        _SubjectResult('Arabic Language', 89, 'B+', 'Ustadh Ali',
            'Strong vocabulary. Reading fluency has improved.'),
        _SubjectResult('Quran Memorisation', 88, 'B+', 'Ustadha Fatima',
            'Memorising at a faster pace.'),
        _SubjectResult('Islamic Studies', 78, 'C+', 'Ustadh Omar',
            'Better participation this term.'),
      ],
      comment:
          'A wonderful term. Commitment to Quran memorisation is commendable. Looking forward to seeing continued progress.',
      teacher: 'Sheikh Ahmed',
    ),
    _TermData(
      overallGrade: 'A', overallScore: 91, attendanceRate: 98,
      subjects: [
        _SubjectResult('Quran Recitation', 95, 'A', 'Sheikh Ahmed',
            'Near-perfect recitation. A role model for the class.'),
        _SubjectResult('Tajweed Rules', 89, 'B+', 'Sheikh Ahmed',
            'All rules mastered to a high standard.'),
        _SubjectResult('Arabic Language', 94, 'A', 'Ustadh Ali',
            'Exceptional performance. Writing skills are outstanding.'),
        _SubjectResult('Quran Memorisation', 92, 'A', 'Ustadha Fatima',
            'Juz Amma complete. Has started on longer surahs.'),
        _SubjectResult('Islamic Studies', 84, 'B', 'Ustadh Omar',
            'Significant improvement. Thoughtful contributions in class.'),
      ],
      comment:
          'An exceptional term. Truly excelled across all subjects. May Allah bless this journey.',
      teacher: 'Sheikh Ahmed',
    ),
  ];

  _TermData get _current => _termData[_termIndex];

  Color get _gradeColor {
    final s = _current.overallScore;
    if (s >= 85) return AppTheme.successGreen;
    if (s >= 70) return AppTheme.goldAccent;
    return AppTheme.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Term selector
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: List.generate(_terms.length, (i) {
              final sel = i == _termIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _termIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.primaryGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      _terms[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            sel ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),

        // Overall grade card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_gradeColor, _gradeColor.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: _gradeColor.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Overall Grade',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(_current.overallGrade,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          height: 1)),
                  Text('${_current.overallScore}% average',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _CardStat(
                      label: 'Attendance',
                      value: '${_current.attendanceRate}%'),
                  const SizedBox(height: 10),
                  _CardStat(
                      label: 'Subjects',
                      value: '${_current.subjects.length}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text('Subject Results',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark)),
        const SizedBox(height: 12),
        ..._current.subjects.map((s) => _SubjectRow(subject: s)),
        const SizedBox(height: 20),

        // Teacher comment
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.format_quote_rounded,
                        color: AppTheme.primaryGreen, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Teacher's Comment",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark)),
                      Text(_current.teacher,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _current.comment,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _SubjectRow extends StatelessWidget {
  final _SubjectResult subject;
  const _SubjectRow({required this.subject});

  Color get _color {
    if (subject.score >= 85) return AppTheme.successGreen;
    if (subject.score >= 70) return AppTheme.goldAccent;
    return AppTheme.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              Text(subject.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subject.teacher,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _DetailChip(
                      label: 'Score',
                      value: '${subject.score}/100'),
                  const SizedBox(width: 12),
                  _DetailChip(label: 'Grade', value: subject.grade),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Teacher's Feedback",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark)),
              const SizedBox(height: 8),
              Text(subject.comment,
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5)),
            ],
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 5,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 2),
                  Text(subject.teacher,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(subject.grade,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _color)),
                Text('${subject.score}/100',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final String value;
  const _DetailChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryGreen)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _CardStat extends StatelessWidget {
  final String label;
  final String value;
  const _CardStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}

class _TermData {
  final String overallGrade;
  final int overallScore;
  final int attendanceRate;
  final List<_SubjectResult> subjects;
  final String comment;
  final String teacher;

  const _TermData({
    required this.overallGrade,
    required this.overallScore,
    required this.attendanceRate,
    required this.subjects,
    required this.comment,
    required this.teacher,
  });
}

// ────────────────────────────────────────────────────────────────────────────
// Fees Tab
// ────────────────────────────────────────────────────────────────────────────

class _FeesTab extends StatefulWidget {
  final String childName;
  const _FeesTab({required this.childName});

  @override
  State<_FeesTab> createState() => _FeesTabState();
}

class _FeesTabState extends State<_FeesTab> {
  late final List<_FeeInvoice> _invoices;

  @override
  void initState() {
    super.initState();
    _invoices = [
      _FeeInvoice(id: 'inv_001', label: 'Term 3 Tuition', amount: 300, status: 'Paid', dueDate: 'May 1, 2026'),
      _FeeInvoice(id: 'inv_002', label: 'Term 3 Materials', amount: 50, status: 'Paid', dueDate: 'May 1, 2026'),
      _FeeInvoice(id: 'inv_003', label: 'Term 3 Activity Fee', amount: 100, status: 'Unpaid', dueDate: 'Jun 1, 2026'),
    ];
  }

  int get _totalDue => _invoices.fold(0, (s, i) => s + i.amount);
  int get _totalPaid => _invoices.where((i) => i.status == 'Paid').fold(0, (s, i) => s + i.amount);
  int get _outstanding => _totalDue - _totalPaid;

  Future<void> _payInvoice(_FeeInvoice invoice) async {
    setState(() => invoice.loading = true);
    try {
      await StripeService.payFee(
        invoiceId: invoice.id,
        amountAed: invoice.amount,
        description: invoice.label,
      );
      setState(() => invoice.status = 'Paid');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${invoice.label} paid successfully.'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return;
      if (mounted) _showError(e.error.localizedMessage ?? 'Payment failed.');
    } catch (_) {
      if (mounted) _showError('Could not reach the server. Please try again.');
    } finally {
      if (mounted) setState(() => invoice.loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppTheme.errorRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _outstanding > 0
                  ? [AppTheme.warningOrange, const Color(0xFFEA580C)]
                  : [AppTheme.successGreen, const Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: (_outstanding > 0 ? AppTheme.warningOrange : AppTheme.successGreen)
                    .withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_outstanding > 0 ? 'Amount Due' : 'All Paid',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              Text(
                _outstanding > 0 ? 'AED $_outstanding' : 'AED 0',
                style: const TextStyle(
                    color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, height: 1),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _FeeStat(label: 'Total Billed', value: 'AED $_totalDue')),
                  Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.3)),
                  Expanded(child: _FeeStat(label: 'Paid', value: 'AED $_totalPaid')),
                ],
              ),
              if (_outstanding > 0) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _payInvoice(
                        _invoices.firstWhere((i) => i.status == 'Unpaid')),
                    icon: const Icon(Icons.payment_rounded, size: 18),
                    label: Text('Pay AED $_outstanding with Stripe'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.warningOrange,
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Invoices',
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        const SizedBox(height: 12),
        ..._invoices.map((inv) => _FeeInvoiceCard(
              invoice: inv,
              onPay: () => _payInvoice(inv),
            )),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _FeeStat extends StatelessWidget {
  final String label;
  final String value;
  const _FeeStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _FeeInvoiceCard extends StatelessWidget {
  final _FeeInvoice invoice;
  final VoidCallback onPay;
  const _FeeInvoiceCard({required this.invoice, required this.onPay});

  @override
  Widget build(BuildContext context) {
    final isPaid = invoice.status == 'Paid';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (isPaid ? AppTheme.successGreen : AppTheme.warningOrange)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
              color: isPaid ? AppTheme.successGreen : AppTheme.warningOrange,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice.label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text(
                  isPaid ? 'Paid on ${invoice.dueDate}' : 'Due ${invoice.dueDate}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('AED ${invoice.amount}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              const SizedBox(height: 6),
              if (isPaid)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Paid',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.successGreen)),
                )
              else if (invoice.loading)
                const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen),
                )
              else
                GestureDetector(
                  onTap: onPay,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.payment_rounded, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Pay',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeeInvoice {
  final String id;
  final String label;
  final int amount;
  String status;
  final String dueDate;
  bool loading = false;

  _FeeInvoice({
    required this.id,
    required this.label,
    required this.amount,
    required this.status,
    required this.dueDate,
  });
}

// ────────────────────────────────────────────────────────────────────────────
// Quran Tab
// ────────────────────────────────────────────────────────────────────────────

class _QuranTab extends StatelessWidget {
  final ChildData child;
  const _QuranTab({required this.child});

  static const _surahData = <String, List<Map<String, dynamic>>>{
    '1': [
      {'name': 'Al-Fatiha (1)', 'progress': 1.0, 'completed': true},
      {'name': 'An-Nas (114)', 'progress': 1.0, 'completed': true},
      {'name': 'Al-Falaq (113)', 'progress': 1.0, 'completed': true},
      {'name': 'Al-Ikhlas (112)', 'progress': 0.85, 'completed': false},
      {'name': 'Al-Masad (111)', 'progress': 0.50, 'completed': false},
      {'name': 'An-Nasr (110)', 'progress': 0.20, 'completed': false},
    ],
    '2': [
      {'name': 'Al-Fatiha (1)', 'progress': 1.0, 'completed': true},
      {'name': 'An-Nas (114)', 'progress': 0.70, 'completed': false},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final surahs = _surahData[child.id] ?? [];
    final done = surahs.where((s) => s['completed'] == true).length;
    final inProgress = surahs.length - done;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary banner
        Container(
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
              _QStat(label: 'Current', value: child.surahProgress),
              _QDiv(),
              _QStat(label: 'Completed', value: '$done'),
              _QDiv(),
              _QStat(label: 'In Progress', value: '$inProgress'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Surah Progress',
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textDark),
        ),
        const SizedBox(height: 12),
        if (surahs.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Text(
                'No progress data yet.',
                style: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.7)),
              ),
            ),
          )
        else
          ...surahs.map((s) => _SurahRow(
                name: s['name'] as String,
                progress: (s['progress'] as num).toDouble(),
                completed: s['completed'] as bool,
              )),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _QStat extends StatelessWidget {
  final String label;
  final String value;
  const _QStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _QDiv extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.3));
}

class _SurahRow extends StatelessWidget {
  final String name;
  final double progress;
  final bool completed;
  const _SurahRow(
      {required this.name, required this.progress, required this.completed});

  @override
  Widget build(BuildContext context) {
    final color = completed ? AppTheme.successGreen : AppTheme.primaryGreen;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed ? Icons.check_circle_rounded : Icons.menu_book_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────

class _SubjectResult {
  final String name;
  final int score;
  final String grade;
  final String teacher;
  final String comment;
  const _SubjectResult(
      this.name, this.score, this.grade, this.teacher, this.comment);
}
