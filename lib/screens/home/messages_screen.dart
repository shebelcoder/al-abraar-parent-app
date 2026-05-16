import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

const _conversations = [
  _Conversation(
    name: 'Sheikh Ahmed',
    lastMessage: 'Abdullah did well in Tajweed today!',
    time: '5:12 PM',
    unread: 2,
    isGroup: false,
    initials: 'SA',
    color: Color(0xFF166534),
  ),
  _Conversation(
    name: 'Ustadha Fatima',
    lastMessage: 'Please ensure Aisha revises Al-Fatiha',
    time: '2:30 PM',
    unread: 1,
    isGroup: false,
    initials: 'UF',
    color: Color(0xFF8B5CF6),
  ),
  _Conversation(
    name: 'Level 2 — Parents Group',
    lastMessage: "Reminder: no class this Friday",
    time: 'Yesterday',
    unread: 5,
    isGroup: true,
    initials: 'PG',
    color: Color(0xFF0EA5E9),
  ),
  _Conversation(
    name: 'Ustadh Ali',
    lastMessage: "Great progress on Arabic vocabulary!",
    time: 'Monday',
    unread: 0,
    isGroup: false,
    initials: 'UA',
    color: Color(0xFFF97316),
  ),
  _Conversation(
    name: 'School Admin',
    lastMessage: 'Term 3 fees are now due.',
    time: 'Last week',
    unread: 0,
    isGroup: false,
    initials: 'AD',
    color: Color(0xFF6366F1),
  ),
];

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  List<_Conversation> get _filtered => _conversations
      .where((c) =>
          c.name.toLowerCase().contains(_query.toLowerCase()) ||
          c.lastMessage.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppTheme.warmBackground,
      appBar: AppBar(
        title: const Text('Messages'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.surfaceWhite,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search messages...',
                hintStyle:
                    const TextStyle(color: AppTheme.textSecondary),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppTheme.textSecondary),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppTheme.textSecondary),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
                fillColor: AppTheme.warmBackground,
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const _EmptyMessages()
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      indent: 72,
                      color: Color(0xFFF3F4F6),
                    ),
                    itemBuilder: (_, i) =>
                        _ConversationTile(conv: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final _Conversation conv;
  const _ConversationTile({required this.conv});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceWhite,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: conv.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  conv.initials,
                  style: TextStyle(
                    color: conv.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            if (conv.isGroup)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.group, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conv.name,
                style: TextStyle(
                  fontWeight: conv.unread > 0
                      ? FontWeight.w700
                      : FontWeight.w600,
                  fontSize: 15,
                  color: AppTheme.textDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              conv.time,
              style: TextStyle(
                fontSize: 12,
                color: conv.unread > 0
                    ? AppTheme.primaryGreen
                    : AppTheme.textSecondary,
                fontWeight: conv.unread > 0
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                conv.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: conv.unread > 0
                      ? AppTheme.textDark
                      : AppTheme.textSecondary,
                  fontWeight: conv.unread > 0
                      ? FontWeight.w500
                      : FontWeight.w400,
                ),
              ),
            ),
            if (conv.unread > 0)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${conv.unread}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        onTap: () => context.push('/chat', extra: {
          'name': conv.name,
          'initials': conv.initials,
          'color': conv.color,
          'isGroup': conv.isGroup,
        }),
      ),
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages();

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
            child: const Icon(Icons.chat_bubble_outline_rounded,
                size: 40, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 16),
          const Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your conversations with teachers\nwill appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Conversation {
  final String name;
  final String lastMessage;
  final String time;
  final int unread;
  final bool isGroup;
  final String initials;
  final Color color;
  const _Conversation({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.isGroup,
    required this.initials,
    required this.color,
  });
}
