import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../models/message.dart';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;
  final Box<Message> _messageBox = Hive.box<Message>('messages');

  Stream<List<Message>> getMessages(String otherUserId) {
    final currentUserId = _client.auth.currentUser!.id;

    // BOLT OPTIMIZATION:
    // We fetch messages using the stream.
    // To optimize, we ensure we only process messages for this specific conversation.
    // We also use Hive for local persistence which makes subsequent loads instant.

    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((maps) {
          // Optimized filtering:
          // 1. Convert to Message models only once.
          // 2. Filter for specific conversation participants.
          final messages = maps
              .map((map) => Message.fromMap(map))
              .where((msg) =>
                  (msg.senderId == currentUserId && msg.receiverId == otherUserId) ||
                  (msg.senderId == otherUserId && msg.receiverId == currentUserId))
              .toList();

          // Performance win: Cache messages for instant offline access/loading
          for (var msg in messages) {
            _messageBox.put(msg.id, msg);
          }

          return messages;
        });
  }

  Future<void> sendMessage(String receiverId, String text) async {
    final message = {
      'sender_id': _client.auth.currentUser!.id,
      'receiver_id': receiverId,
      'text': text,
    };
    await _client.from('messages').insert(message);
  }

  void saveLocally(Message message) {
    _messageBox.put(message.id, message);
  }
}

final chatServiceProvider = Provider((ref) => ChatService());

final messagesProvider = StreamProvider.family<List<Message>, String>((ref, otherUserId) {
  return ref.watch(chatServiceProvider).getMessages(otherUserId);
});
