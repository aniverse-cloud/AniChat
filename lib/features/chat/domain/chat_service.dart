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

  RealtimeChannel? _broadcastChannel;
  StreamSubscription<AuthState>? _authStateSubscription;

  // BOLT OPTIMIZATION: Cache messages in memory by conversation to avoid O(N) box scans.
  final Map<String, List<Message>> _chatCache = {};
  final Map<String, StreamController<List<Message>>> _controllers = {};

  ChatService() {
    _initRealtime();
    // Listen for auth changes to re-initialize realtime subscription
    _authStateSubscription = _client.auth.onAuthStateChange.listen((data) {
      _initRealtime();
    });
  }

  void dispose() {
    _authStateSubscription?.cancel();
    _broadcastChannel?.unsubscribe();
  }

  String _getConvId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  void _initRealtime() {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      _broadcastChannel?.unsubscribe();
      _broadcastChannel = null;
      return;
    }

    // Unsubscribe from previous if exists
    _broadcastChannel?.unsubscribe();

    // Listen to messages broadcasted to the user's personal channel
    _broadcastChannel = _client.channel('user_messages_$currentUserId')
      ..onBroadcast(
        event: 'new_message',
        callback: (payload) async {
          final messageMap = payload['message'] as Map<String, dynamic>;
          final message = Message.fromMap(messageMap);
          _saveMessageLocally(message);
          await _updateContactLastMessage(message);
        },
      )
      ..subscribe();
  }

  void _saveMessageLocally(Message message) {
    if (!_messageBox.containsKey(message.id)) {
      _messageBox.put(message.id, message);

      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) return;

      final otherId = message.senderId == currentUserId ? message.receiverId : message.senderId;
      final convId = _getConvId(currentUserId, otherId);

      if (_chatCache.containsKey(convId)) {
        _chatCache[convId]!.add(message);
        // Sort is O(K log K) where K is messages in this chat, MUCH faster than O(N) box scan
        _chatCache[convId]!.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        _controllers[convId]?.add(List.from(_chatCache[convId]!));
      }
    }
  }

  Future<void> _updateContactLastMessage(Message message) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return;

    final otherUserId =
        message.senderId == currentUserId ? message.receiverId : message.senderId;

    var contact = _contactBox.get(otherUserId);

    if (contact == null) {
      // BOLT OPTIMIZATION: Automatic profile discovery for unknown senders
      try {
        final data = await _client
            .from('profiles')
            .select()
            .eq('id', otherUserId)
            .maybeSingle();

        if (data != null) {
          contact = Contact(
            id: data['id'],
            username: data['username'] ?? 'User',
            phone: data['phone'],
            avatarUrl: data['avatar_url'],
          );
        }
      } catch (e) {
        // Fallback
        contact = Contact(
          id: otherUserId,
          username: 'User',
        );
      }
    }

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
    final convId = _getConvId(currentUserId, otherUserId);

    if (!_controllers.containsKey(convId)) {
      _controllers[convId] = StreamController<List<Message>>.broadcast();

      // Warm up cache if empty (First time opening this chat in current session)
      if (!_chatCache.containsKey(convId)) {
        _chatCache[convId] = _messageBox.values.where((msg) {
          return (msg.senderId == currentUserId && msg.receiverId == otherUserId) ||
              (msg.senderId == otherUserId && msg.receiverId == currentUserId);
        }).toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      }

      _controllers[convId]!.add(_chatCache[convId]!);
    }

    return _controllers[convId]!.stream;
  }

  Future<void> sendMessage(String receiverId, String text) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return;

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
    await _updateContactLastMessage(message);

    // 2. Broadcast via Supabase Realtime
    try {
      await _client.channel('user_messages_$receiverId').sendBroadcastMessage(
        event: 'new_message',
        payload: {'message': message.toMap()},
      );
    } catch (e) {
      // Broadcast error handled silently
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
    if (!_contactBox.containsKey(contact.id)) {
      _contactBox.put(contact.id, contact);
    }
  }

  // BOLT OPTIMIZATION: Sync local contacts with Supabase profiles for up-to-date discovery
  Future<void> syncContacts() async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) return;

      final data = await _client.from('profiles').select();
      final List<dynamic> profiles = data as List<dynamic>;

      for (var profile in profiles) {
        if (profile['id'] == currentUserId) continue;

        final contact = Contact(
          id: profile['id'],
          username: profile['username'] ?? 'User',
          phone: profile['phone'],
          avatarUrl: profile['avatar_url'],
        );

        // Update if exists or add new
        final existing = _contactBox.get(contact.id);
        if (existing != null) {
          // Preserve last message info
          _contactBox.put(
            contact.id,
            contact.copyWith(
              lastMessage: existing.lastMessage,
              lastMessageTime: existing.lastMessageTime,
            ),
          );
        } else {
          _contactBox.put(contact.id, contact);
        }
      }
    } catch (e) {
      // Sync error
    }
  }

  Stream<List<Contact>> getContactsStream() async* {
    // Initial value
    yield _contactBox.values.toList();
    // Subsequent values
    await for (final _ in _contactBox.watch()) {
      yield _contactBox.values.toList();
    }
  }
}

final chatServiceProvider = Provider((ref) {
  final service = ChatService();
  ref.onDispose(() => service.dispose());
  return service;
});

final messagesProvider = StreamProvider.family<List<Message>, String>((ref, otherUserId) {
  return ref.watch(chatServiceProvider).getMessagesStream(otherUserId);
});

final contactsProvider = StreamProvider<List<Contact>>((ref) {
  return ref.watch(chatServiceProvider).getContactsStream();
});
