import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotifType { reminder, message, grade, announcement, fee }

class AppNotification {
  final int id;
  final NotifType type;
  final String title;
  final String body;
  final String time;
  final String group;
  final bool read;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.group,
    required this.read,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        time: time,
        group: group,
        read: read ?? this.read,
      );
}

final _seed = <AppNotification>[
  AppNotification(
    id: 1,
    type: NotifType.reminder,
    title: "Abdullah's class in 30 minutes",
    body: 'Quran Recitation with Sheikh Ahmed starts at 5:00 PM',
    time: '4:30 PM',
    group: 'Today',
    read: false,
  ),
  AppNotification(
    id: 2,
    type: NotifType.message,
    title: 'New message from Sheikh Ahmed',
    body: "Abdullah did well in today's Tajweed session. Keep practising!",
    time: '2:00 PM',
    group: 'Today',
    read: false,
  ),
  AppNotification(
    id: 3,
    type: NotifType.grade,
    title: 'New mark posted for Abdullah',
    body: 'Tajweed assessment has been marked: 88/100',
    time: '11:00 AM',
    group: 'Today',
    read: false,
  ),
  AppNotification(
    id: 4,
    type: NotifType.announcement,
    title: 'Level 2 — Parents Group',
    body: 'Reminder: no class this Friday due to public holiday.',
    time: 'Yesterday',
    group: 'Yesterday',
    read: true,
  ),
  AppNotification(
    id: 5,
    type: NotifType.grade,
    title: 'Report card available for Aisha',
    body: 'Term 2 report card is now ready to view.',
    time: 'Yesterday',
    group: 'Yesterday',
    read: true,
  ),
  AppNotification(
    id: 6,
    type: NotifType.fee,
    title: 'Fee reminder',
    body: 'Term 3 activity fee of AED 100 is due by Jun 1.',
    time: '2 days ago',
    group: 'Earlier',
    read: true,
  ),
  AppNotification(
    id: 7,
    type: NotifType.grade,
    title: 'Aisha completed Al-Fatiha!',
    body: "Aisha has memorised Al-Fatiha perfectly. Masha'Allah!",
    time: '3 days ago',
    group: 'Earlier',
    read: true,
  ),
];

class NotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() => List.from(_seed);

  void markRead(int id) {
    state = state.map((n) => n.id == id ? n.copyWith(read: true) : n).toList();
  }

  void markAllRead() {
    state = state.map((n) => n.copyWith(read: true)).toList();
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
        NotificationsNotifier.new);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.read).length;
});
