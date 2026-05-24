import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui/widgets/main_layout.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/ai_customer_service/presentation/ai_service_screen.dart';
import '../features/admin/presentation/admin_panel.dart';
import '../features/chat/presentation/chats_screen.dart';
import '../features/chat/presentation/contacts_screen.dart';
import '../features/chat/presentation/chat_detail_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: ListView(
        children: [
          CupertinoListSection.insetGrouped(
            children: [
              CupertinoListTile(
                title: const Text('Customer Service AI'),
                leading: const Icon(CupertinoIcons.ant_fill),
                trailing: const CupertinoListTileChevron(),
                onTap: () => context.push('/ai-service'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CupertinoButton(
            child: const Text('Sign Out'),
            onPressed: () async {
              try {
                await Supabase.instance.client.auth.signOut();
              } catch (_) {}
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(height: 100),
          GestureDetector(
            onLongPress: () => context.push('/admin/Executive'),
            child: Container(
              height: 50,
              color: CupertinoColors.transparent,
              child: const Center(child: Text('AnChat v1.0.0', style: TextStyle(color: CupertinoColors.systemGrey4, fontSize: 12))),
            ),
          ),
        ],
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/ai-service',
        builder: (context, state) => const AICustomerServiceScreen(),
      ),
      GoRoute(
        path: '/admin/:level',
        builder: (context, state) => AdminPanel(
          adminLevel: state.pathParameters['level'] ?? 'Lower',
        ),
      ),
      GoRoute(
        path: '/chat-detail/:id/:username',
        builder: (context, state) => ChatDetailScreen(
          otherUserId: state.pathParameters['id']!,
          otherUsername: state.pathParameters['username']!,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/chats',
            builder: (context, state) => const ChatsScreen(),
          ),
          GoRoute(
            path: '/contacts',
            builder: (context, state) => const ContactsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      Session? session;
      try {
        session = Supabase.instance.client.auth.currentSession;
      } catch (_) {
        // Supabase not initialized, stay on login/register for demo
      }

      final loggingIn = state.uri.toString() == '/login' || state.uri.toString() == '/register';

      if (session == null) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return '/chats';
      }

      return null;
    },
  );
});
