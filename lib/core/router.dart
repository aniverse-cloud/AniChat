import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui/widgets/main_layout.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/ai_customer_service/presentation/ai_service_screen.dart';
import '../features/admin/presentation/admin_panel.dart';

// Placeholder Screens
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Chats'),
      ),
      child: Center(child: Text('Messages will appear here')),
    );
  }
}

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Contacts'),
      ),
      child: Center(child: Text('Your contacts list')),
    );
  }
}

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
              // Admin Panel is now hidden and accessible via secret method (noted in README)
            ],
          ),
          const SizedBox(height: 20),
          CupertinoButton(
            child: const Text('Sign Out'),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(height: 100),
          // Secret activation area
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
      final session = Supabase.instance.client.auth.currentSession;
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
