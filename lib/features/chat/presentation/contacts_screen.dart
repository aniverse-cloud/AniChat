import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = Supabase.instance.client;

    // In a real app, we would have a 'profiles' table.
    // For this demo, we'll try to fetch users or show a search.
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Contacts'),
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: client.from('profiles').select(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }

          final profiles = snapshot.data ?? [];
          final currentUserId = client.auth.currentUser?.id;
          final otherProfiles = profiles.where((p) => p['id'] != currentUserId).toList();

          if (otherProfiles.isEmpty) {
            return const Center(child: Text('No other users found.'));
          }

          return ListView.builder(
            itemCount: otherProfiles.length,
            itemBuilder: (context, index) {
              final profile = otherProfiles[index];
              return CupertinoListTile(
                title: Text(profile['username'] ?? 'User'),
                subtitle: Text(profile['id']),
                leading: const Icon(CupertinoIcons.person_circle_fill),
                trailing: const CupertinoListTileChevron(),
                onTap: () {
                  context.push('/chat-detail/${profile['id']}/${profile['username']}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
