import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../models/message.dart';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;
  final Box<Message> _messageBox = Hive.box<Message>('messages');

  Stream<List<Message>> getMessages(String otherUserId) {
    final currentUserId = _client.auth.currentUser!.id;

    // Filter for messages between current user and other user
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((maps) {
          return maps
              .map((map) => Message.fromMap(map))
              .where((msg) =>
                  (msg.senderId == currentUserId && msg.receiverId == otherUserId) ||
                  (msg.senderId == otherUserId && msg.receiverId == currentUserId))
              .toList();
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
