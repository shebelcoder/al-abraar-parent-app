import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<_Notif> _notifs;

  static final _initial = [
    _Notif(
      id: 1,
      type: _NType.reminder,
      title: "Abdullah's class in 30 minutes",
      body: 'Quran Recitation with Sheikh Ahmed starts at 5:00 PM',
      time: '4:30 PM',
      group: 'Today',
      read: false,
    ),
    _Notif(
      id: 2,
      type: _NType.grade,
      title: 'New mark posted for Abdullah',
      body: 'Tajweed assessment has been marked: 88/100',
      time: '2:00 PM',
      group: 'Today',
      read: false,
    ),
    _Notif(
      id: 3,
      type: _NType.message,
      title: 'New message from Sheikh Ahmed',
      body: "Abdullah did well in today's class. Keep up the practice!",
      time: '1:00 PM',
      group: 'Today',
      read: false,
    ),
    _Notif(
      id: 4,
      type: _NType.announcement,
      title: 'Level 2 — Parents Group',
      body: "Reminder: no class this Friday due to public holiday.",
      time: 'Yesterday',
      group: 'Yesterday',
      read: true,
    ),
    _Notif(
      id: 5,
      type: _NType.grade,
      title: 'Report card available for Aisha',
      body: 'Term 2 report card is now ready to view.',
      time: 'Yesterday',
      group: 'Yesterday',
      read: true,
    ),
    _Notif(
      id: 6,
      type: _NType.fee,
      title: 'Fee reminder',
      body: 'Term 3 fees are due by end of this month.',
      time: '2 days ago',
      group: 'Earlier',
      read: true,
    ),
    _Notif(
      id: 7,
      type: _NType.achievement,
      title: 'Aisha completed Al-Fatiha!',
      body: "Aisha has memorised Al-Fatiha perfectly. Masha'Allah!",
      time: '3 days ago',
      group: 'Earlier',
      read: true,
    ),
    _Notif(
      id: 8,
      type: _NType.reminder,
      title: 'Attendance notice',
      body: "Abdullah's attendance this month is 92%. Keep it up!",
      time: '4 days ago',
      group: 'Earlier',
      read: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _notifs = List.from(_initial);
  }

  int get _unreadCount => _notifs.where((n) => !n.read).length;

  void _markAllRead() =>
      setState(() => _notifs = _notifs.map((n) => n.copyWith(read: true)).toList());

  void _markRead(int id) => setState(() => _notifs =
      _notifs.map((n) => n.id == id ? n.copyWith(read: true) : n).toList());

  @override
  Widget build(BuildContext context) {
    const groups = ['Today', 'Yesterday', 'Earlier'];
    return Scaffold(
      backgroundColor: AppTheme.warmBackground,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: _notifs.isEmpty
          ? const _Empty()
          : ListView(
              children: [
                for (final group in groups) ...[
                  if (_notifs.any((n) => n.group == group)) ...[
                    _GroupHeader(label: group),
                    ..._notifs
                        .where((n) => n.group == group)
                        .map((n) => _NotifTile(
                              notif: n,
                              onTap: () => _markRead(n.id),
                            )),
                  ],
                ],
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;
  const _GroupHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final _Notif notif;
  final VoidCallback onTap;
  const _NotifTile({required this.notif, required this.onTap});

  Color get _accent {
    switch (notif.type) {
      case _NType.reminder:
        return AppTheme.primaryGreen;
      case _NType.message:
        return const Color(0xFF0EA5E9);
      case _NType.achievement:
        return AppTheme.goldAccent;
      case _NType.grade:
        return const Color(0xFF8B5CF6);
      case _NType.announcement:
        return AppTheme.warningOrange;
      case _NType.fee:
        return AppTheme.errorRed;
    }
  }

  IconData get _icon {
    switch (notif.type) {
      case _NType.reminder:
        return Icons.alarm_rounded;
      case _NType.message:
        return Icons.chat_bubble_rounded;
      case _NType.achievement:
        return Icons.emoji_events_rounded;
      case _NType.grade:
        return Icons.grade_rounded;
      case _NType.announcement:
        return Icons.campaign_rounded;
      case _NType.fee:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.read
              ? AppTheme.surfaceWhite
              : _accent.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: notif.read
              ? null
              : Border(left: BorderSide(color: _accent, width: 3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.read
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      Text(
                        notif.time,
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (!notif.read)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8, top: 4),
                decoration:
                    BoxDecoration(color: _accent, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

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
            child: const Icon(Icons.notifications_none_rounded,
                size: 40, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 16),
          const Text('All caught up!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
          const SizedBox(height: 6),
          const Text('No new notifications',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

enum _NType { reminder, message, achievement, grade, announcement, fee }

class _Notif {
  final int id;
  final _NType type;
  final String title;
  final String body;
  final String time;
  final String group;
  final bool read;

  const _Notif({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.group,
    required this.read,
  });

  _Notif copyWith({bool? read}) => _Notif(
        id: id,
        type: type,
        title: title,
        body: body,
        time: time,
        group: group,
        read: read ?? this.read,
      );
}
