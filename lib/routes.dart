import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/home/home_screen.dart';
import 'features/pantry/pantry_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/community/community_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/recipe_detail/recipe_detail_screen.dart';
import 'features/welcome_screen/welcome_screen.dart';
import 'core/widgets/bottom_nav.dart';

// Creating a key for the scaffold to control the bottom navigation
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/welcome',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: [
      // Welcome screen route
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder:
                (context, state) => NoTransitionPage(child: const HomeScreen()),
          ),
          GoRoute(
            path: '/pantry',
            name: 'pantry',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const PantryScreen()),
          ),
          GoRoute(
            path: '/chat',
            name: 'chat',
            pageBuilder:
                (context, state) => NoTransitionPage(child: const ChatScreen()),
          ),
          GoRoute(
            path: '/community',
            name: 'community',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const CommunityScreen()),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/recipe/:id',
        name: 'recipe_detail',
        builder: (context, state) {
          final recipeId = state.extra as String? ?? '';
          return RecipeDetailScreen(recipeId: recipeId);
        },
      ),
    ],
  );
}
