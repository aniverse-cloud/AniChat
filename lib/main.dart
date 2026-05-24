import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/supabase_config.dart';
import 'core/router.dart';
import 'ui/theme/theme.dart';
import 'models/message.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(MessageAdapter());
  await Hive.openBox<Message>('messages');

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
