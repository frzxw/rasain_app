import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // List of all available routes in the app with gradient colors
    final List<Map<String, dynamic>> routes = [
      {
        'name': 'Home',
        'route': '/',
        'icon': Icons.home_outlined,
        'gradient': [Colors.orange.shade400, Colors.orange.shade600],
        'note': 'Rekomendasi resep populer dan pencarian resep',
      },
      {
        'name': 'Pantry',
        'route': '/pantry',
        'icon': Icons.kitchen_outlined,
        'gradient': [Colors.green.shade400, Colors.green.shade600],
        'note': 'Kelola bahan makanan di rumah Anda',
      },
      {
        'name': 'Detail Resep',
        'route': '/recipe/1',
        'icon': Icons.receipt_long_outlined,
        'gradient': [Colors.blue.shade400, Colors.blue.shade600],
        'note': 'Panduan lengkap memasak dengan mode step-by-step',
      },
      {
        'name': 'Upload Resep',
        'route': '/upload-recipe',
        'icon': Icons.add_circle_outline,
        'gradient': [Colors.purple.shade400, Colors.purple.shade600],
        'note': 'Bagikan resep istimewa Anda ke komunitas',
      },
      {
        'name': 'Community',
        'route': '/community',
        'icon': Icons.people_outline,
        'gradient': [Colors.pink.shade400, Colors.pink.shade600],
        'note': 'Berbagi dan eksplorasi hasil masakan',
      },
      {
        'name': 'Profile',
        'route': '/profile',
        'icon': Icons.person_outline,
        'gradient': [Colors.indigo.shade400, Colors.indigo.shade600],
        'note': 'Kelola profil dan pengaturan akun',
      },
      {
        'name': 'Notifications',
        'route': '/notifications',
        'icon': Icons.notifications_outlined,
        'gradient': [Colors.teal.shade400, Colors.teal.shade600],
        'note': 'Pantau aktivitas dan update terbaru',
      },
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              Colors.white,
              AppColors.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section with App Branding
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  children: [
                    // App Logo with Shadow
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSizes.marginL),

                    // App Title with Enhanced Typography
                    ShaderMask(
                      shaderCallback:
                          (bounds) => LinearGradient(
                            colors: [AppColors.primary, Colors.orange.shade600],
                          ).createShader(bounds),
                      child: Text(
                        'Rasain App',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.marginS),

                    // Subtitle with elegant styling
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: AppSizes.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        'Kelompok 24',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.marginL),

                    // Feature Highlight
                    Text(
                      'Jelajahi Fitur Aplikasi',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation Cards Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                  ),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: AppSizes.marginM,
                          mainAxisSpacing: AppSizes.marginM,
                        ),
                    itemCount: routes.length,
                    itemBuilder: (context, index) {
                      final route = routes[index];
                      return _buildFeatureCard(
                        context,
                        route['name'],
                        route['route'],
                        route['icon'],
                        route['gradient'],
                        route['note'],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.marginL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String label,
    String route,
    IconData icon,
    List<Color> gradientColors,
    String note,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => GoRouter.of(context).go(route),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with background
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                ),

                const SizedBox(height: AppSizes.marginM),

                // Title
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSizes.marginS),

                // Description
                Text(
                  note,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
