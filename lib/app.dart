import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/theme.dart';
import 'routes.dart';
import 'services/services_initializer.dart';

// Import cubits
import 'cubits/auth/auth_cubit.dart';
import 'cubits/recipe/recipe_cubit.dart';
import 'cubits/pantry/pantry_cubit.dart';
import 'cubits/chat/chat_cubit.dart';
import 'cubits/notification/notification_cubit.dart';
import 'cubits/community/community_cubit.dart';

class RasainApp extends StatelessWidget {
  const RasainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize all cubits after the app is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCubits(context);
    });

    // Use a simplified theme approach with only light theme
    final ThemeData lightTheme = AppTheme.getLightTheme();

    return MaterialApp.router(
      title: 'Rasain',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      routerConfig: createRouter(),
    );
  }

  // Initialize all cubits
  void _initializeCubits(BuildContext context) async {
    // Initialize authentication cubit
    await context.read<AuthCubit>().initialize();

    // Initialize recipe cubit
    await context.read<RecipeCubit>().initialize();

    // Initialize pantry cubit
    await context.read<PantryCubit>().initialize();

    // Initialize chat cubit
    await context.read<ChatCubit>().initialize();

    // Initialize notification cubit
    await context.read<NotificationCubit>().initialize();

    // Initialize community cubit
    await context.read<CommunityCubit>().initialize();
  }
}
