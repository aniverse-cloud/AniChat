import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../ui/widgets/glass_widgets.dart';
import '../domain/chat_service.dart';
import '../../../models/contact.dart';

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

  void _addNewContact() {
    final phoneController = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Add Contact'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: CupertinoTextField(
            controller: phoneController,
            placeholder: 'Enter phone number',
            keyboardType: TextInputType.phone,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Add'),
            onPressed: () async {
              final phone = phoneController.text.trim();
              if (phone.isEmpty) return;

              final contact =
                  await ref.read(chatServiceProvider).findUserByPhone(phone);
              if (mounted) {
                if (contact != null) {
                  ref.read(chatServiceProvider).addContact(contact);
                  Navigator.pop(context);
                } else {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Not Found'),
                      content: const Text('No user found with that phone number.'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);

    return CupertinoPageScaffold(
      child: GlassmorphicBackground(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: const Text('Contacts',
                  style: TextStyle(color: CupertinoColors.white)),
              backgroundColor: CupertinoColors.transparent,
              border: null,
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _addNewContact,
                child: const Icon(CupertinoIcons.person_add_solid,
                    color: CupertinoColors.white),
              ),
            ),
            SliverFillRemaining(
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
                                style: const TextStyle(
                                    color: CupertinoColors.white)),
                            subtitle: Text(contact.id,
                                style: TextStyle(
                                    color: CupertinoColors.white
                                        .withValues(alpha: 0.5),
                                    fontSize: 12)),
                            leading: const Icon(
                                CupertinoIcons.person_circle_fill,
                                color: CupertinoColors.white,
                                size: 40),
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
                loading: () =>
                    const Center(child: CupertinoActivityIndicator()),
                error: (err, stack) => Center(
                    child: Text('Error: $err',
                        style: const TextStyle(color: CupertinoColors.white))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
