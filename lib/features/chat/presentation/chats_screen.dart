import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = Supabase.instance.client;
    final currentUserId = client.auth.currentUser?.id;

    if (currentUserId == null) return const Center(child: Text('Not logged in'));

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Chats'),
      ),
      child: Stack(
        children: [
          _buildChatList(context, client),
          Positioned(
            bottom: 24,
            right: 24,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => context.push('/contacts'),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.activeBlue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.plus,
                  color: CupertinoColors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(BuildContext context, SupabaseClient client) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        // Fetch unique users the current user has messaged
        future: client.rpc('get_my_chats'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }

          // Fallback if RPC is not defined yet: show some recent messages
          if (snapshot.hasError) {
             return Center(child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Icon(CupertinoIcons.chat_bubble_2, size: 64, color: CupertinoColors.systemGrey),
                 const SizedBox(height: 16),
                 const Text('No conversations yet'),
                 CupertinoButton(
                   child: const Text('Start Chatting'),
                   onPressed: () => context.go('/contacts'),
                 )
               ],
             ));
          }

          final chats = snapshot.data ?? [];

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return CupertinoListTile(
                title: Text(chat['username'] ?? 'User'),
                subtitle: Text(chat['last_message'] ?? ''),
                leading: const Icon(CupertinoIcons.person_circle_fill),
                onTap: () {
                   context.push('/chat-detail/${chat['id']}/${chat['username']}');
                },
              );
            },
          );
        },
      );
  }
}
