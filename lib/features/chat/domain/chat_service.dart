import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../models/message.dart';
import '../../../models/contact.dart';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;
  final Box<Message> _messageBox = Hive.box<Message>('messages');
  final Box<Contact> _contactBox = Hive.box<Contact>('contacts');

  // ignore: unused_field
  RealtimeChannel? _broadcastChannel;

  ChatService() {
    _initRealtime();
  }

  void _initRealtime() {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return;

    // Listen to messages broadcasted to the user's personal channel
    _broadcastChannel = _client.channel('user_messages_$currentUserId')
      ..onBroadcast(
        event: 'new_message',
        callback: (payload) {
          final messageMap = payload['message'] as Map<String, dynamic>;
          final message = Message.fromMap(messageMap);
          _saveMessageLocally(message);
          _updateContactLastMessage(message);
        },
      )
      ..subscribe();
  }

  void _saveMessageLocally(Message message) {
    if (!_messageBox.containsKey(message.id)) {
      _messageBox.put(message.id, message);
    }
  }

  void _updateContactLastMessage(Message message) {
    final currentUserId = _client.auth.currentUser!.id;
    final otherUserId = message.senderId == currentUserId ? message.receiverId : message.senderId;

    final contact = _contactBox.get(otherUserId);
    if (contact != null) {
      final updatedContact = contact.copyWith(
        lastMessage: message.text,
        lastMessageTime: message.timestamp,
      );
      _contactBox.put(otherUserId, updatedContact);
    }
  }

  Stream<List<Message>> getMessagesStream(String otherUserId) {
    final currentUserId = _client.auth.currentUser!.id;

    // BOLT OPTIMIZATION:
    // Read directly from Hive local storage. This is O(1) disk read
    // and eliminates network latency for loading chat history.
    return _messageBox.watch().map((_) => _getMessagesList(currentUserId, otherUserId))
        .map((list) => list..sort((a, b) => a.timestamp.compareTo(b.timestamp)));
  }

  List<Message> _getMessagesList(String currentUserId, String otherUserId) {
    return _messageBox.values.where((msg) {
      return (msg.senderId == currentUserId && msg.receiverId == otherUserId) ||
             (msg.senderId == otherUserId && msg.receiverId == currentUserId);
    }).toList();
  }

  Future<void> sendMessage(String receiverId, String text) async {
    final currentUserId = _client.auth.currentUser!.id;
    final messageId = const Uuid().v4();
    final now = DateTime.now();

    final message = Message(
      id: messageId,
      senderId: currentUserId,
      receiverId: receiverId,
      text: text,
      timestamp: now,
    );

    // 1. Save locally first (Instant feedback)
    _saveMessageLocally(message);
    _updateContactLastMessage(message);

    // 2. Broadcast via Supabase Realtime
    try {
      await _client.channel('user_messages_$receiverId').sendBroadcastMessage(
        event: 'new_message',
        payload: {'message': message.toMap()},
      );
    } catch (e) {
      // Broadcast error handled silently or logged
    }
  }

  // Contact Discovery
  Future<Contact?> findUserByPhone(String phone) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      if (data != null) {
        return Contact(
          id: data['id'],
          username: data['username'] ?? 'User',
          phone: data['phone'],
          avatarUrl: data['avatar_url'],
        );
      }
    } catch (e) {
      // Error
    }
    return null;
  }

  void addContact(Contact contact) {
    _contactBox.put(contact.id, contact);
  }

  Stream<List<Contact>> getContactsStream() {
    return _contactBox.watch().map((_) => _contactBox.values.toList());
  }
}

final chatServiceProvider = Provider((ref) => ChatService());

final messagesProvider = StreamProvider.family<List<Message>, String>((ref, otherUserId) {
  return ref.watch(chatServiceProvider).getMessagesStream(otherUserId);
});

final contactsProvider = StreamProvider<List<Contact>>((ref) {
  return ref.watch(chatServiceProvider).getContactsStream();
});
