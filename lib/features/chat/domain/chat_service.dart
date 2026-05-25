import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../models/message.dart';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;
  final Box<Message> _messageBox = Hive.box<Message>('messages');

  String _getConversationId(String u1, String u2) {
    final ids = [u1, u2]..sort();
    return ids.join('_');
  }

  Stream<List<Message>> getMessages(String otherUserId) {
    final currentUserId = _client.auth.currentUser!.id;
    final conversationId = _getConversationId(currentUserId, otherUserId);

    // BOLT OPTIMIZATION:
    // 1. Server-side filtering using 'conversation_id' column.
    //    This significantly reduces data transfer and client-side processing
    //    by only streaming messages for the active conversation.
    // 2. Efficient Hive caching: Only write messages that aren't already present,
    //    avoiding redundant disk I/O on every stream update.

    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map((maps) {
          final messages = maps.map((map) => Message.fromMap(map)).toList();

          // Performance win: Cache messages efficiently
          for (var msg in messages) {
            if (!_messageBox.containsKey(msg.id)) {
              _messageBox.put(msg.id, msg);
            }
          }

          return messages;
        });
  }

  Future<void> sendMessage(String receiverId, String text) async {
    final currentUserId = _client.auth.currentUser!.id;
    final conversationId = _getConversationId(currentUserId, receiverId);

    final message = {
      'sender_id': currentUserId,
      'receiver_id': receiverId,
      'text': text,
      'conversation_id': conversationId,
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
