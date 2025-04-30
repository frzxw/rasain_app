import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'auth_service.dart';
import 'recipe_service.dart';
import 'pantry_service.dart';
import 'chat_service.dart';
import 'mock_data.dart';

/// Helper class to initialize all services with the Indonesian mock data
class ServicesInitializer {
  /// Create and initialize all service providers for the app
  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider(
        create: (_) => AuthService(),
        lazy: false,
      ),
      ChangeNotifierProvider(
        create: (_) => RecipeService(),
      ),
      ChangeNotifierProvider(
        create: (_) => PantryService(),
      ),
      ChangeNotifierProvider(
        create: (_) => ChatService(),
      ),
    ];
  }

  /// Initialize all services with mock data
  static Future<void> initializeServices(BuildContext context) async {
    // Initialize auth service (login a mock user)
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.checkAuth();

    // Initialize recipe service
    final recipeService = Provider.of<RecipeService>(context, listen: false);
    await recipeService.initialize();

    // Initialize pantry service
    final pantryService = Provider.of<PantryService>(context, listen: false);
    await pantryService.initialize();

    // Initialize chat service
    final chatService = Provider.of<ChatService>(context, listen: false);
    await chatService.initialize();

    debugPrint('All services initialized with Indonesian mock data');
  }
}