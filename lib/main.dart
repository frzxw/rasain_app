import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'services/auth_service.dart';
import 'services/recipe_service.dart';
import 'services/pantry_service.dart';
import 'services/chat_service.dart';
import 'services/notification_service.dart';
import 'core/theme/theme_service.dart';
import 'core/config/supabase_config.dart';
import 'services/data_service.dart';

// Import cubits
import 'cubits/auth/auth_cubit.dart';
import 'cubits/recipe/recipe_cubit.dart';
import 'cubits/pantry/pantry_cubit.dart';
import 'cubits/chat/chat_cubit.dart';
import 'cubits/notification/notification_cubit.dart';
import 'cubits/community/community_cubit.dart';
import 'cubits/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Create service instances
  final themeService = ThemeService();
  final authService = AuthService();
  final recipeService = RecipeService();
  final pantryService = PantryService();
  final chatService = ChatService();
  final notificationService = NotificationService();
  final dataService = DataService();

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
        // Service providers
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: recipeService),
        ChangeNotifierProvider.value(value: pantryService),
        ChangeNotifierProvider.value(value: chatService),
        ChangeNotifierProvider.value(value: notificationService),
        Provider.value(value: dataService),

        // BloC/Cubit providers
        BlocProvider(
          create: (context) => ThemeCubit(themeService)..initialize(),
        ),
        BlocProvider(create: (context) => AuthCubit(authService)),
        BlocProvider(create: (context) => RecipeCubit(recipeService)),
        BlocProvider(create: (context) => PantryCubit(pantryService)),
        BlocProvider(create: (context) => ChatCubit(chatService)),
        BlocProvider(
          create: (context) => NotificationCubit(notificationService),
        ),
        BlocProvider(create: (context) => CommunityCubit(dataService)),
      ],
      child: const RasainApp(),
    ),
  );
}
