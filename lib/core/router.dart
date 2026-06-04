import 'package:flutter/material.dart';
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
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/edit_profile_screen.dart';

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
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chats',
                builder: (context, state) => const ChatsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/contacts',
                builder: (context, state) => const ContactsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
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
