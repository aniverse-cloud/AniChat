import 'package:flutter_test/flutter_test.dart';
import 'package:anchat/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('AnChat smoke test', (tester) async {
    // Build our app and trigger a frame.
    // We ignore the actual rendering of login screen because Supabase isn't initialized in tests
    await tester.pumpWidget(
      const ProviderScope(
        child: AnChatApp(),
      ),
    );

    // Verify that the app widget is created
    expect(find.byType(AnChatApp), findsOneWidget);
  });
}
