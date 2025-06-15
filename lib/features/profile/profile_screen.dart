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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              onUpdateSettings: (notifications, language, _) async {
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.updateSettings(
                  notificationsEnabled: notifications,
                  language: language,
                  darkModeEnabled: false, // Always false since we removed dark mode
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
                label: 'Tersimpan', // Changed to Indonesian
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
                label: 'Postingan', // Changed to Indonesian
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
              'Masuk untuk mengakses profil Anda', // Changed to Indonesian
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginM),
            Text(
              'Simpan resep favorit Anda, lacak perjalanan memasak Anda, dan terhubung dengan komunitas', // Changed to Indonesian
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
                child: const Text('Masuk'), // Changed to Indonesian
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
                child: const Text('Buat Akun'), // Changed to Indonesian
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
      barrierDismissible: false, // Prevent dismissing during loading
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Consumer<AuthService>(
          builder: (context, authService, _) => AlertDialog(
            title: const Text('Masuk'),
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
                      enabled: !authService.isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan email Anda';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.marginM),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Kata Sandi',
                        prefixIcon: Icon(Icons.lock_outlined),
                      ),
                      obscureText: true,
                      enabled: !authService.isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan password Anda';
                        }
                        return null;
                      },
                    ),
                    if (authService.error != null) ...[
                      const SizedBox(height: AppSizes.marginM),
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingS),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: AppColors.error, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authService.error!,
                                style: TextStyle(color: AppColors.error, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (authService.isLoading) ...[
                      const SizedBox(height: AppSizes.marginM),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Masuk...', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: authService.isLoading ? null : () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => _showPasswordResetDialog(context, emailController.text),
                child: const Text('Lupa Password?'),
              ),
              ElevatedButton(
                onPressed: authService.isLoading ? null : () async {
                  if (formKey.currentState!.validate()) {
                    final success = await authService.login(
                      emailController.text.trim(),
                      passwordController.text,
                    );
                    
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Berhasil masuk!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Masuk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _showRegisterDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Consumer<AuthService>(
          builder: (context, authService, _) => AlertDialog(
            title: const Text('Buat Akun'),
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
                        labelText: 'Nama',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                      enabled: !authService.isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan nama Anda';
                        }
                        if (value.length < 2) {
                          return 'Nama minimal 2 karakter';
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
                      enabled: !authService.isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan email Anda';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.marginM),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Kata Sandi',
                        prefixIcon: Icon(Icons.lock_outlined),
                      ),
                      obscureText: true,
                      enabled: !authService.isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan password';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.marginM),
                    TextFormField(
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Konfirmasi Kata Sandi',
                        prefixIcon: Icon(Icons.lock_outlined),
                      ),
                      obscureText: true,
                      enabled: !authService.isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password Anda';
                        }
                        if (value != passwordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),
                    if (authService.error != null) ...[
                      const SizedBox(height: AppSizes.marginM),
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingS),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: AppColors.error, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authService.error!,
                                style: TextStyle(color: AppColors.error, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (authService.isLoading) ...[
                      const SizedBox(height: AppSizes.marginM),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Mendaftar...', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: authService.isLoading ? null : () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: authService.isLoading ? null : () async {
                  if (formKey.currentState!.validate()) {
                    final success = await authService.register(
                      nameController.text.trim(),
                      emailController.text.trim(),
                      passwordController.text,
                    );
                    
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Akun berhasil dibuat! Silakan cek email untuk verifikasi.'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPasswordResetDialog(BuildContext context, String? email) {
    final TextEditingController emailController = TextEditingController(text: email);
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Consumer<AuthService>(
          builder: (context, authService, _) => AlertDialog(
            title: const Text('Reset Password'),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Masukkan email Anda untuk menerima link reset password.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: AppSizes.marginM),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      enabled: !authService.isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan email Anda';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    if (authService.error != null) ...[
                      const SizedBox(height: AppSizes.marginM),
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingS),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: AppColors.error, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authService.error!,
                                style: TextStyle(color: AppColors.error, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (authService.isLoading) ...[
                      const SizedBox(height: AppSizes.marginM),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Mengirim...', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: authService.isLoading ? null : () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: authService.isLoading ? null : () async {
                  if (formKey.currentState!.validate()) {
                    final success = await authService.resetPassword(emailController.text.trim());
                    
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link reset password telah dikirim ke email Anda.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Kirim'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
