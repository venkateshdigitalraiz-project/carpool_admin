import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final List<Map<String, dynamic>> _threads = [
    {
      'id': 'msg-1',
      'name': 'Sarah Jenkins (Driver)',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      'route': 'Downtown Terminal → Grand Central',
      'lastMessage': 'I will be at Platform 3 by 8:20 AM. White Tesla Model 3 with hazards on.',
      'time': '10:14 AM',
      'unread': 1,
      'messages': [
        {'isMe': false, 'text': 'Hi! Thanks for booking my ride to Grand Central.'},
        {'isMe': true, 'text': 'Hello Sarah! Will you have space for one medium trolley?'},
        {'isMe': false, 'text': 'Yes definitely! The trunk has plenty of space.'},
        {'isMe': false, 'text': 'I will be at Platform 3 by 8:20 AM. White Tesla Model 3 with hazards on.'},
      ],
    },
    {
      'id': 'msg-2',
      'name': 'Marc Lefebvre (Driver)',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      'route': 'Westwood Blvd → San Diego Harbor',
      'lastMessage': 'See you at Westwood! Traffic looks clear today.',
      'time': 'Yesterday',
      'unread': 0,
      'messages': [
        {'isMe': false, 'text': 'See you at Westwood! Traffic looks clear today.'},
      ],
    },
    {
      'id': 'msg-3',
      'name': 'Lucas Morel (Driver)',
      'avatar': 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
      'route': 'University District → Ski Resort',
      'lastMessage': 'Do you have ski gear with you?',
      'time': '2 days ago',
      'unread': 0,
      'messages': [
        {'isMe': false, 'text': 'Do you have ski gear with you?'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Inbox & Messages', style: AppTypography.titleLarge),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _threads.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.borderLight),
        itemBuilder: (context, index) {
          final thread = _threads[index];
          final bool hasUnread = (thread['unread'] as int) > 0;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(thread['avatar']),
                  onBackgroundImageError: (error, stack) {},
                  child: Text(thread['name'][0]),
                ),
                if (hasUnread)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    thread['name'],
                    style: AppTypography.titleMedium.copyWith(
                      fontSize: 15,
                      fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  thread['time'],
                  style: AppTypography.bodySmall.copyWith(
                    color: hasUnread ? AppColors.primary : AppColors.textTertiary,
                    fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  thread['route'],
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  thread['lastMessage'],
                  style: AppTypography.bodyMedium.copyWith(
                    color: hasUnread ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            onTap: () {
              setState(() {
                thread['unread'] = 0;
              });
              _openChatScreen(context, thread);
            },
          );
        },
      ),
    );
  }

  void _openChatScreen(BuildContext context, Map<String, dynamic> thread) {
    final textController = TextEditingController();
    final List<Map<String, dynamic>> messages = List.from(thread['messages'] as List);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setChatState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(thread['avatar']),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(thread['name'], style: AppTypography.titleMedium),
                              Text(thread['route'], style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => ctx.pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  // Chat message list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, idx) {
                        final msg = messages[idx];
                        final bool isMe = msg['isMe'] as bool;
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primary : AppColors.inputFill,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              msg['text'],
                              style: TextStyle(
                                color: isMe ? Colors.white : AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Chat Input Bar
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      10,
                      16,
                      MediaQuery.of(context).viewInsets.bottom + 12,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textController,
                            decoration: const InputDecoration(
                              hintText: 'Type your message...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              fillColor: AppColors.inputFill,
                              filled: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: AppColors.primary),
                          onPressed: () {
                            if (textController.text.trim().isNotEmpty) {
                              setChatState(() {
                                messages.add({
                                  'isMe': true,
                                  'text': textController.text.trim(),
                                });
                              });
                              setState(() {
                                thread['lastMessage'] = textController.text.trim();
                              });
                              textController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
