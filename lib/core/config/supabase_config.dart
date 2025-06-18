import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrlKey = 'SUPABASE_URL';
  static const String supabaseAnonKeyKey = 'SUPABASE_ANON_KEY';

  static String get supabaseUrl {
    final url = dotenv.env[supabaseUrlKey];
    if (url == null || url.isEmpty) {
      throw Exception('SUPABASE_URL not found in environment variables');
    }
    return url;
  }

  static String get supabaseAnonKey {
    final key = dotenv.env[supabaseAnonKeyKey];
    if (key == null || key.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY not found in environment variables');
    }
    return key;
  }

  static Future<void> initialize() async {
    try {
      debugPrint('🔧 Loading environment variables...');
      await dotenv.load(fileName: '.env');

      final url = supabaseUrl;
      final key = supabaseAnonKey;

      debugPrint('🔧 Initializing Supabase...');
      debugPrint('URL: $url');
      debugPrint('Key: ${key.substring(0, 20)}...');

      await Supabase.initialize(url: url, anonKey: key, debug: kDebugMode);

      debugPrint('✅ Supabase initialized successfully');

      // Test connection
      final client = Supabase.instance.client;
      final response = await client.from('recipes').select('count').limit(1);
      debugPrint(
        '🧪 Database connection test successful: ${response.length} recipes found',
      );
    } catch (e) {
      debugPrint('❌ Error initializing Supabase: $e');
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
