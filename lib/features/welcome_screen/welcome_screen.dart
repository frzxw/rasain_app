import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List of all available routes in the app
    final List<Map<String, dynamic>> routes = [
      {'name': 'Home', 'route': '/', 'icon': Icons.home_outlined},
      {'name': 'Pantry', 'route': '/pantry', 'icon': Icons.kitchen_outlined},
      {'name': 'Chat', 'route': '/chat', 'icon': Icons.chat_outlined},
      {
        'name': 'Community',
        'route': '/community',
        'icon': Icons.people_outline,
      },
      {'name': 'Profile', 'route': '/profile', 'icon': Icons.person_outline},
      // We can't add recipe_detail here as it requires a recipe ID
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Title and Logo
              const SizedBox(height: AppSizes.marginXL),
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.restaurant,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSizes.marginL),
                    Text(
                      'Rasain App',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.marginS),
                    const SizedBox(height: AppSizes.marginS),
                    Text(
                      'Kelompok 24',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.marginXL),

              // Navigation Section Title
              Padding(
                padding: const EdgeInsets.only(left: AppSizes.paddingS),
                child: Text(
                  'Navigate to:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),

              const SizedBox(height: AppSizes.marginL),

              // Navigation Buttons
              Expanded(
                child: ListView.separated(
                  itemCount: routes.length,
                  separatorBuilder:
                      (context, index) =>
                          const SizedBox(height: AppSizes.marginM),
                  itemBuilder: (context, index) {
                    final route = routes[index];
                    return _buildNavigationButton(
                      context,
                      route['name'],
                      route['route'],
                      route['icon'],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    String label,
    String route,
    IconData icon,
  ) {
    return CustomButton(
      label: label,
      onPressed: () => GoRouter.of(context).go(route),
      icon: icon,
      iconAtEnd: false,
      variant: ButtonVariant.primary,
    );
  }
}
