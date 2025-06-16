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
    await dotenv.load(fileName: '.env');
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false,
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
}