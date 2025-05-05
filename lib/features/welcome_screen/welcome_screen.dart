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
      {
        'name': 'Home',
        'route': '/',
        'icon': Icons.home_outlined,
        'note':
            '- Berisi rekomendasi resep, resep populer. Merupakan homescreen dari app.\n- Terdapat fitur search untuk mencari resep.',
      },
      {
        'name': 'Pantry',
        'route': '/pantry',
        'icon': Icons.kitchen_outlined,
        'note':
            '- Tempat menyimpan bahan makanan yang ada di rumah.\n- Terdapat fitur untuk menambahkan bahan makanan dan menghapusnya.',
      },
      {
        'name': 'Detail Resep',
        'route': '/recipe/1',
        'icon': Icons.receipt_long_outlined,
        'note':
            '- Terdapat informasi resep lebih detail (waktu, porsi, dan estimasi biaya).\n- Terdapat bahan dan langkah-langkah memasak.\n- User dapat berpindah ke mode memasak yang menjelaskan langkah satu persatu  \n- User dapat memberikan dan melihat ulasan dan rating.',
      },
      {
        'name': 'Chat',
        'route': '/chat',
        'icon': Icons.chat_outlined,
        'note':
            '- Chatbot untuk membantu menjawab pertanyaan seputar resep atau memasak.',
      },
      {
        'name': 'Community',
        'route': '/community',
        'icon': Icons.people_outline,
        'note':
            '- Tempat untuk berbagi hasil masakan resep dan tips memasak\n- User dapat memberikan like, komentar, dan share resep.',
      },
      {
        'name': 'Profile',
        'route': '/profile',
        'icon': Icons.person_outline,
        'note':
            '- Tempat untuk mengatur profil pengguna.\n- Login dan logout user dilakukan di sini.\n- Untuk tampilan tanpa akun dapat klik tombol logout.',
      },
      {
        'name': 'Notifications',
        'route': '/notifications',
        'icon': Icons.notifications_outlined,
        'note':
            '- Tempat untuk melihat notifikasi terkait aktivitas pengguna.\n- Notifikasi dapat berupa komentar, like, atau update lainnya.',
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingS),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Title and Logo
              const SizedBox(height: AppSizes.marginS),
              Center(
                child: Column(
                  children: [
                    // const Icon(
                    //   Icons.restaurant,
                    //   size: 80,
                    //   color: AppColors.primary,
                    // ),
                    // const SizedBox(height: AppSizes.marginL),
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

              const SizedBox(height: AppSizes.marginM),

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
                      route['note'],
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
    String note,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          label: label,
          onPressed: () => GoRouter.of(context).go(route),
          icon: icon,
          iconAtEnd: false,
          variant: ButtonVariant.primary,
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.paddingM,
            top: AppSizes.paddingXS,
            bottom: AppSizes.paddingS,
          ),
          child: Text(
            note,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
