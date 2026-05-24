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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    ref.read(chatServiceProvider).sendMessage(
          widget.otherUserId,
          _messageController.text.trim(),
        );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.otherUsername),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: ref.watch(chatServiceProvider).getMessages(widget.otherUserId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CupertinoActivityIndicator());
                  final messages = snapshot.data!;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      final isMe = message.senderId != widget.otherUserId;
                      return _buildMessageBubble(message, isMe);
                    },
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
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
              style: TextStyle(color: isMe ? CupertinoColors.white : CupertinoColors.black),
            ),
          ),
          Text(
            DateFormat('HH:mm').format(message.timestamp),
            style: const TextStyle(fontSize: 10, color: CupertinoColors.systemGrey),
          ),
        ],
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
