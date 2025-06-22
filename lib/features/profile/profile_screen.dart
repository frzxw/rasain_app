import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/auth_dialog.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/recipe/recipe_cubit.dart';
import '../../cubits/recipe/recipe_state.dart';
import '../../models/user_profile.dart';
import 'edit_profile_screen.dart';
import 'widgets/saved_recipe_list.dart';
import 'widgets/user_recipe_list.dart';
import 'widgets/profile_menu_new.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if user is authenticated
      context.read<AuthCubit>().initialize();

      // Load saved recipes
      context.read<RecipeCubit>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Profile'),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final isAuthenticated = state.status == AuthStatus.authenticated;
          final user = state.user;

          if (state.status == AuthStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          return isAuthenticated && user != null
              ? _buildAuthenticatedProfile(context, user)
              : _buildUnauthenticatedProfile(context);
        },
      ),
    );
  }

  Widget _buildAuthenticatedProfile(BuildContext context, UserProfile user) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AuthCubit>().initialize();
        await context.read<RecipeCubit>().initialize();
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(context, user),

            const SizedBox(height: AppSizes.marginL),

            // Saved Recipes
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resep Tersimpan', // Changed to Indonesian
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    '${user.savedRecipesCount} tersimpan', // Changed to Indonesian
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.marginM),

            // Saved Recipe List
            BlocBuilder<RecipeCubit, RecipeState>(
              builder: (context, state) {
                return SavedRecipeList(
                  recipes: state.savedRecipes,
                  isLoading: state.status == RecipeStatus.loading,
                );
              },
            ),

            const SizedBox(height: AppSizes.marginL),

            // User Recipe List - Resep Buatan Saya
            BlocBuilder<RecipeCubit, RecipeState>(
              builder: (context, state) {
                return UserRecipeList(
                  recipes: state.userRecipes,
                  isLoading: state.status == RecipeStatus.loading,
                );
              },
            ),

            const SizedBox(height: AppSizes.marginL),

            // Settings and Profile Menu
            ProfileMenu(
              user: user,
              onLogout: () async {
                await context.read<AuthCubit>().signOut();
              },
              onUpdateSettings: (notifications, language, _) async {
                final success = await context.read<AuthCubit>().updateSettings(
                  notifications,
                  language ?? 'id',
                );

                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengaturan berhasil diperbarui'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: AppSizes.marginXL),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.primary, width: 2),
              image:
                  user.imageUrl != null
                      ? DecorationImage(
                        image: NetworkImage(user.imageUrl!),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                user.imageUrl == null
                    ? const Icon(
                      Icons.person,
                      size: AppSizes.iconXL,
                      color: AppColors.textSecondary,
                    )
                    : null,
          ),

          const SizedBox(height: AppSizes.marginM),

          // User Name
          Text(
            user.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),

          if (user.email != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.paddingXS),
              child: Text(
                user.email!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),

          const SizedBox(height: AppSizes.marginM),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(
                context,
                count: user.savedRecipesCount,
                label: 'Tersimpan', // Changed to Indonesian
              ),
              Container(
                height: 24,
                width: 1,
                color: AppColors.border,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSizes.marginL,
                ),
              ),
              _buildStatItem(
                context,
                count: user.postsCount,
                label: 'Postingan', // Changed to Indonesian
              ),
            ],
          ),

          const SizedBox(height: AppSizes.marginL),

          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(userProfile: user),
                  ),
                );

                if (result == true && context.mounted) {
                  // Refresh profile data
                  context.read<AuthCubit>().initialize();
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingM,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required int count,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildUnauthenticatedProfile(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle_outlined,
              size: 100,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.marginL),
            Text(
              'Masuk untuk mengakses profil Anda', // Changed to Indonesian
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginM),
            Text(
              'Simpan resep favorit Anda, lacak perjalanan memasak Anda, dan terhubung dengan komunitas', // Changed to Indonesian
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {                  // Show unified auth dialog starting with login
                  AuthDialog.showAuthDialog(
                    context,
                    startWithLogin: true,
                    redirectMessage: 'Masuk ke akun Anda untuk mengakses profil dan fitur lengkap.',
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingM,
                  ),
                ),
                child: const Text('Masuk'), // Changed to Indonesian
              ),
            ),
            const SizedBox(height: AppSizes.marginM),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {                  // Show unified auth dialog starting with registration
                  AuthDialog.showAuthDialog(
                    context,
                    startWithLogin: false,
                    redirectMessage: 'Buat akun baru untuk menikmati semua fitur Rasain.',
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingM,
                  ),
                ),
                child: const Text('Buat Akun'), // Changed to Indonesian
              ),
            ),
          ],
        ),
      ),
    );
  }
}
