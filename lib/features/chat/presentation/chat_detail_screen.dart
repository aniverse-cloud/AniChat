import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/chat_service.dart';
import '../../../models/message.dart';
import 'package:intl/intl.dart';
import '../../../ui/widgets/glass_widgets.dart';

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
      child: GlassmorphicBackground(
        child: Column(
          children: [
            CupertinoNavigationBar(
              middle: Text(widget.otherUsername,
                  style: const TextStyle(color: CupertinoColors.white)),
              backgroundColor: CupertinoColors.transparent,
              border: null,
            ),
            Expanded(
              child: messagesAsync.when(
                data: (messages) => ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  addAutomaticKeepAlives: true,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
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
                error: (err, stack) => Center(
                    child: Text('Error: $err',
                        style: const TextStyle(color: CupertinoColors.white))),
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return GlassCard(
      blur: 20,
      opacity: 0.1,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: _messageController,
              placeholder: 'AnChat message...',
              placeholderStyle:
                  TextStyle(color: CupertinoColors.white.withValues(alpha: 0.5)),
              style: const TextStyle(color: CupertinoColors.white),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: CupertinoColors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: CupertinoColors.white.withValues(alpha: 0.2)),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _sendMessage,
            child: const Icon(CupertinoIcons.arrow_up_circle_fill,
                size: 32, color: CupertinoColors.white),
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
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe
                  ? CupertinoColors.activeBlue.withValues(alpha: 0.8)
                  : CupertinoColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 18),
              ),
              border: Border.all(
                color: CupertinoColors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              message.text,
              style: const TextStyle(
                color: CupertinoColors.white,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('HH:mm').format(message.timestamp),
            style: TextStyle(
              fontSize: 10,
              color: CupertinoColors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
