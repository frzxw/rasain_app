import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_bar.dart';
import '../../services/auth_service.dart';
import '../../services/recipe_service.dart';
import '../../models/user_profile.dart';
import 'widgets/saved_recipe_list.dart';
import 'widgets/profile_menu.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

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
      final authService = Provider.of<AuthService>(context, listen: false);
      authService.checkAuth();
      
      // Load saved recipes
      final recipeService = Provider.of<RecipeService>(context, listen: false);
      recipeService.fetchSavedRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Profile',
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, _) {
          final isAuthenticated = authService.isAuthenticated;
          final user = authService.currentUser;
          
          if (authService.isLoading) {
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
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.checkAuth();
        
        final recipeService = Provider.of<RecipeService>(context, listen: false);
        await recipeService.fetchSavedRecipes();
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
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saved Recipes',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    '${user.savedRecipesCount} saved',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSizes.marginM),
            
            // Saved Recipe List
            Consumer<RecipeService>(
              builder: (context, recipeService, _) {
                return SavedRecipeList(
                  recipes: recipeService.savedRecipes,
                  isLoading: recipeService.isLoading,
                );
              },
            ),
            
            const SizedBox(height: AppSizes.marginL),
            
            // Settings and Profile Menu
            ProfileMenu(
              user: user,
              onLogout: () async {
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.logout();
              },
              onUpdateSettings: (notifications, language, darkMode) async {
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.updateSettings(
                  notificationsEnabled: notifications,
                  language: language,
                  darkModeEnabled: darkMode,
                );
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
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
              image: user.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(user.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user.imageUrl == null
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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
                label: 'Saved',
              ),
              Container(
                height: 24,
                width: 1,
                color: AppColors.border,
                margin: const EdgeInsets.symmetric(horizontal: AppSizes.marginL),
              ),
              _buildStatItem(
                context,
                count: user.postsCount,
                label: 'Posts',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {required int count, required String label}) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
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
              'Sign in to access your profile',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginM),
            Text(
              'Save your favorite recipes, track your cooking journey, and connect with the community',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Show login dialog
                  _showLoginDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                ),
                child: const Text('Sign In'),
              ),
            ),
            const SizedBox(height: AppSizes.marginM),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Show registration dialog
                  _showRegisterDialog(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                ),
                child: const Text('Create Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.marginM),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                
                // Attempt login
                final authService = Provider.of<AuthService>(context, listen: false);
                final success = await authService.login(
                  emailController.text.trim(),
                  passwordController.text,
                );
                
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authService.error ?? 'Login failed. Please try again.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  void _showRegisterDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Account'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.marginM),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.marginM),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                
                // Attempt registration
                final authService = Provider.of<AuthService>(context, listen: false);
                final success = await authService.register(
                  nameController.text.trim(),
                  emailController.text.trim(),
                  passwordController.text,
                );
                
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authService.error ?? 'Registration failed. Please try again.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}
