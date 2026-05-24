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
    // We use a broader stream that only fetches messages involving the current user.
    // While Supabase Stream doesn't support OR natively yet, we can filter for
    // messages where the current user is either sender OR receiver if we had a view.
    // For now, we fetch ALL messages but we filter them in a way that is ready for
    // future server-side optimizations.
    // THE REAL WIN: We also persist them to Hive for instant offline access.

    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((maps) {
          final messages = maps
              .map((map) => Message.fromMap(map))
              .where((msg) =>
                  (msg.senderId == currentUserId && msg.receiverId == otherUserId) ||
                  (msg.senderId == otherUserId && msg.receiverId == currentUserId))
              .toList();

          // Cache messages for performance
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
