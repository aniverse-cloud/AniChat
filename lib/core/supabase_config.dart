import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://ovnypxyfkaizzggdbypu.supabase.co';
  static const String anonKey = 'sb_publishable_6PUsFayKGmwqx26pJxkJKg_NF8a03wx';

  // Gemini API Key for Customer Service AI
  static const String geminiApiKey = 'AIzaSyCkjNM-RjgCKZPVPXn_wqRrfCdYKA8AFzQ';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}
