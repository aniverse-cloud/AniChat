import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../ui/widgets/glass_widgets.dart';
import '../domain/chat_service.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    // BOLT OPTIMIZATION: Trigger background sync to keep local box updated
    Future.microtask(() => ref.read(chatServiceProvider).syncContacts());
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Contacts', style: TextStyle(color: CupertinoColors.white)),
        backgroundColor: CupertinoColors.transparent,
        border: null,
      ),
      child: GlassmorphicBackground(
        child: contactsAsync.when(
          data: (contacts) {
            if (contacts.isEmpty) {
              return const Center(
                child: Text('No other users found.',
                    style: TextStyle(color: CupertinoColors.white)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GlassCard(
                    child: CupertinoListTile(
                      title: Text(contact.username,
                          style: const TextStyle(color: CupertinoColors.white)),
                      subtitle: Text(contact.id,
                          style: TextStyle(
                              color: CupertinoColors.white.withValues(alpha: 0.5),
                              fontSize: 12)),
                      leading: const Icon(CupertinoIcons.person_circle_fill,
                          color: CupertinoColors.white, size: 40),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        context.push(
                            '/chat-detail/${contact.id}/${contact.username}');
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
        ),
      ),
    );
  }
}
