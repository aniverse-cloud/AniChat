import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/chat_service.dart';
import '../../../models/message.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  final String otherUsername;

  const ChatDetailScreen({
    super.key,
    required this.otherUserId,
    required this.otherUsername,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    ref.read(chatServiceProvider).sendMessage(
          widget.otherUserId,
          text,
        );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.otherUserId));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.otherUsername),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                data: (messages) => ListView.builder(
                  addAutomaticKeepAlives: true,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    // Optimization: We reverse the list for the UI, but
                    // ListView.builder with reverse: true handles index 0 as bottom.
                    // The messages from Supabase are ordered by created_at.
                    // To show latest at bottom (index 0 in reverse list),
                    // we pick from end of list.
                    final message = messages[messages.length - 1 - index];
                    final isMe = message.senderId != widget.otherUserId;
                    return MessageBubble(
                      key: ValueKey(message.id),
                      message: message,
                      isMe: isMe,
                    );
                  },
                ),
                loading: () => const Center(child: CupertinoActivityIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: CupertinoColors.systemBackground,
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: _messageController,
              placeholder: 'AnChat message...',
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(20),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _sendMessage,
            child: const Icon(CupertinoIcons.arrow_up_circle_fill, size: 32),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? CupertinoColors.activeBlue : CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: isMe ? CupertinoColors.white : CupertinoColors.black,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('HH:mm').format(message.timestamp),
            style: const TextStyle(
              fontSize: 10,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}
