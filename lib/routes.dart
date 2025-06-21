import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/home/home_screen.dart';
import 'features/pantry/pantry_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/community/community_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/recipe_detail/modern_recipe_detail_screen.dart';
import 'features/notifications/notifications_screen.dart'; // Added notifications screen
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/email_verification_screen.dart';
import 'core/widgets/bottom_nav.dart';
import 'features/welcome_screen/welcome_screen.dart';

// App routes constants to use throughout the app
class AppRoutes {
  static const String home = '/';
  static const String pantry = '/pantry';
  static const String chat = '/chat';
  static const String community = '/community';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String recipeDetail = '/recipe';
}

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
      // Auth routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/email-verification',
        name: 'email_verification',
        builder: (context, state) => const EmailVerificationScreen(),
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
      ),      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/recipe/:slug',
        name: 'recipe_detail',
        builder: (context, state) {
          // Use params() method to get recipe slug
          final recipeSlug = state.params['slug'] ?? '';
          return ModernRecipeDetailScreen(recipeSlug: recipeSlug);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}
