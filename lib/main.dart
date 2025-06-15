import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/auth_service.dart';
import 'services/recipe_service.dart';
import 'services/pantry_service.dart';
import 'services/chat_service.dart';
import 'services/notification_service.dart';
import 'services/supabase_service.dart';
import 'core/theme/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  bool envLoaded = false;
  
  // Try loading from root directory first
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ Environment variables loaded from root");
    envLoaded = true;
  } catch (e) {
    debugPrint("⚠️ Could not load .env from root: $e");
  }
  
  // If that didn't work, try the assets directory
  if (!envLoaded) {
    try {
      await dotenv.load(fileName: "assets/.env");
      debugPrint("✅ Environment variables loaded from assets directory");
      envLoaded = true;
    } catch (e) {
      debugPrint("⚠️ Could not load .env from assets: $e");
    }
  }
  
  // If no .env file was loaded, use hardcoded values in debug mode
  if (!envLoaded && kDebugMode) {
    debugPrint("⚠️ Using hardcoded environment variables for development");
    dotenv.env['SUPABASE_URL'] = 'https://quxpdapjcslwlxhzcxkv.supabase.co';
    dotenv.env['SUPABASE_ANON_KEY'] = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF1eHBkYXBqY3Nsd2x4aHpjeGt2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2MDgxNzcsImV4cCI6MjA2NTE4NDE3N30.-9T7-VGjAAwwSb9dEHBpX9injf_mfBai9-tT0oihz0o';
  }
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Create service instances to manage app state
  final themeService = ThemeService();
  final authService = AuthService();
  
  // Set system UI overlay style for light mode
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider(create: (_) => RecipeService()),
        ChangeNotifierProvider(create: (_) => PantryService()),
        ChangeNotifierProvider(create: (_) => ChatService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
      ],
      child: const RasainApp(),
    ),
  );
}
