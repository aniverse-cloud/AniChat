import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/supabase_config.dart';
import 'core/router.dart';
import 'ui/theme/theme.dart';
import 'models/message.dart';
import 'models/contact.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request permissions on startup
  await [
    Permission.camera,
    Permission.storage,
    Permission.photos,
  ].request();

  await Hive.initFlutter();
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(ContactAdapter());
  await Hive.openBox<Message>('messages');
  await Hive.openBox<Contact>('contacts');

  try {
    if (SupabaseConfig.url != 'YOUR_SUPABASE_URL') {
      await SupabaseConfig.initialize();
    }
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  runApp(
    const ProviderScope(
      child: AnChatApp(),
    ),
  );
}

class AnChatApp extends ConsumerWidget {
  const AnChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return CupertinoApp.router(
      title: 'AnChat',
      theme: AnChatTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
