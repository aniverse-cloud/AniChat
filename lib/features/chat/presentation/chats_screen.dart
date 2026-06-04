import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../ui/widgets/glass_widgets.dart';
import '../domain/chat_service.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = Supabase.instance.client;
    final currentUserId = client.auth.currentUser?.id;

    if (currentUserId == null) return const Center(child: Text('Not logged in'));

    return CupertinoPageScaffold(
      child: GlassmorphicBackground(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                const CupertinoSliverNavigationBar(
                  largeTitle: Text('Chats', style: TextStyle(color: CupertinoColors.white)),
                  backgroundColor: CupertinoColors.transparent,
                  border: null,
                ),
                SliverFillRemaining(
                  child: _buildChatList(context, ref),
                ),
              ],
            ),
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
                    color: CupertinoColors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: CupertinoColors.white.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withValues(alpha: 0.1),
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
      ),
    );
  }

  Widget _buildChatList(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider);

    return contactsAsync.when(
      data: (contacts) {
        final chats = contacts
            .where((c) => c.lastMessage != null)
            .toList()
          ..sort((a, b) => (b.lastMessageTime ?? DateTime(0))
              .compareTo(a.lastMessageTime ?? DateTime(0)));

        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.chat_bubble_2,
                    size: 64, color: CupertinoColors.systemGrey),
                const SizedBox(height: 16),
                const Text('No conversations yet',
                    style: TextStyle(color: CupertinoColors.white)),
                CupertinoButton(
                  child: const Text('Start Chatting'),
                  onPressed: () => context.push('/contacts'),
                )
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GlassCard(
                child: CupertinoListTile(
                  title: Text(chat.username,
                      style: const TextStyle(color: CupertinoColors.white)),
                  subtitle: Text(chat.lastMessage ?? '',
                      style: TextStyle(
                          color: CupertinoColors.white.withValues(alpha: 0.7))),
                  leading: const Icon(CupertinoIcons.person_circle_fill,
                      color: CupertinoColors.white, size: 40),
                  onTap: () {
                    context.push('/chat-detail/${chat.id}/${chat.username}');
                  },
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (err, stack) => Center(
          child: Text('Error: $err',
              style: const TextStyle(color: CupertinoColors.white))),
    );
  }
}
