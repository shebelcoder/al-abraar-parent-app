import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../theme/app_theme.dart';

class _Message {
  final String text;
  final bool isMine;
  final DateTime sentAt;

  const _Message({
    required this.text,
    required this.isMine,
    required this.sentAt,
  });
}

class ChatScreen extends StatefulWidget {
  final String contactName;
  final String contactInitials;
  final Color contactColor;
  final bool isGroup;

  const ChatScreen({
    super.key,
    required this.contactName,
    required this.contactInitials,
    required this.contactColor,
    this.isGroup = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_Message> _messages = [
    _Message(
      text: 'Assalamu alaikum, hope you are well',
      isMine: false,
      sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    _Message(
      text: 'Wa alaikum assalam! Alhamdulillah. How is my child doing?',
      isMine: true,
      sentAt:
          DateTime.now().subtract(const Duration(days: 1, hours: 2, minutes: 55)),
    ),
    _Message(
      text:
          'Alhamdulillah, great progress this week! Tajweed is improving nicely.',
      isMine: false,
      sentAt:
          DateTime.now().subtract(const Duration(days: 1, hours: 2, minutes: 50)),
    ),
    _Message(
      text: 'JazakAllah khair for the update. Should we practice more at home?',
      isMine: true,
      sentAt:
          DateTime.now().subtract(const Duration(days: 1, hours: 2, minutes: 40)),
    ),
    _Message(
      text:
          'Yes, please review Surah Al-Ikhlas daily and practice the makharij rules we covered.',
      isMine: false,
      sentAt:
          DateTime.now().subtract(const Duration(days: 1, hours: 2, minutes: 35)),
    ),
    _Message(
      text: 'In sha Allah, we will. Barakallah feek!',
      isMine: true,
      sentAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  bool get _canSend => _textCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text: text, isMine: true, sentAt: DateTime.now()));
      _textCtrl.clear();
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: widget.contactColor.withValues(alpha: 0.15),
              child: Text(
                widget.contactInitials,
                style: TextStyle(
                  color: widget.contactColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.contactName,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(
                    widget.isGroup ? 'Group' : 'Teacher',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Calling is not available yet'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                final showDate =
                    i == 0 || !_sameDay(_messages[i - 1].sentAt, msg.sentAt);
                return Column(
                  children: [
                    if (showDate) _DateDivider(date: msg.sentAt),
                    _Bubble(message: msg),
                  ],
                );
              },
            ),
          ),
          _InputBar(
            controller: _textCtrl,
            canSend: _canSend,
            onSend: _sendMessage,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(_label(),
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
          ),
          const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _Message message;
  const _Bubble({required this.message});

  String _timeLabel(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) const SizedBox(width: 4),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine ? AppTheme.primaryGreen : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMine ? 18 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMine ? Colors.white : AppTheme.textDark,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeLabel(message.sentAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMine
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMine) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool canSend;
  final VoidCallback onSend;
  final ValueChanged<String> onChanged;

  const _InputBar({
    required this.controller,
    required this.canSend,
    required this.onSend,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle:
                        const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.warmBackground,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                          color: AppTheme.primaryGreen, width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: canSend
                    ? AppTheme.primaryGreen
                    : const Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.send_rounded,
                    size: 20,
                    color: canSend ? Colors.white : AppTheme.textSecondary),
                onPressed: canSend ? onSend : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
