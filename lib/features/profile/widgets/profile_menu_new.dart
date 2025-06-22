import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../cubits/auth/auth_cubit.dart';
import '../../../cubits/auth/auth_state.dart';
import '../../../models/user_profile.dart';

class ProfileMenu extends StatefulWidget {
  final UserProfile user;
  final VoidCallback onLogout;

  const ProfileMenu({super.key, required this.user, required this.onLogout});

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Settings Header
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Pengaturan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(
            height: AppSizes.marginS,
          ), // Account Management Section Card
          _buildSectionCard(
            title: 'Akun',
            children: [
              // Logout
              _buildMenuButton(
                icon: Icons.logout,
                title: 'Keluar',
                onTap: () => _confirmLogout(context),
                iconColor: AppColors.error,
                textColor: AppColors.error,
              ),

              _buildDivider(),

              // Delete Account
              _buildMenuButton(
                icon: Icons.delete_outline,
                title: 'Hapus Akun',
                onTap: () => _showDeleteAccountDialog(context),
                iconColor: AppColors.error,
                textColor: AppColors.error,
              ),
            ],
          ),

          const SizedBox(height: AppSizes.marginL),

          // App Info
          Center(
            child: Column(
              children: [
                Text(
                  'Rasain v1.0.0',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2025 Rasain App',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border, width: 0.5),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusS),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.paddingM,
          horizontal: AppSizes.paddingS,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: AppSizes.iconM - 2,
              ),
            ),
            const SizedBox(width: AppSizes.marginM),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: textColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: AppSizes.iconS,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: AppSizes.marginL,
      thickness: 0.5,
      color: AppColors.divider,
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => BlocBuilder<AuthCubit, AuthState>(
            builder:
                (context, state) => AlertDialog(
                  title: const Text('Keluar'),
                  content:
                      state.status == AuthStatus.loading
                          ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 16),
                              Text('Keluar...'),
                            ],
                          )
                          : const Text('Apakah Anda yakin ingin keluar?'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  actions:
                      state.status == AuthStatus.loading
                          ? []
                          : [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                widget.onLogout();
                                Navigator.pop(dialogContext);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                              ),
                              child: const Text('Keluar'),
                            ),
                          ],
                ),
          ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (dialogContext, setState) => BlocBuilder<AuthCubit, AuthState>(
                  builder:
                      (context, state) => AlertDialog(
                        title: const Text('Hapus Akun'),
                        content: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Tindakan ini tidak dapat dibatalkan. Semua data Anda akan dihapus secara permanen.',
                                style: TextStyle(color: AppColors.error),
                              ),

                              const SizedBox(height: AppSizes.marginM),

                              // Password Confirmation
                              TextFormField(
                                controller: passwordController,
                                decoration: const InputDecoration(
                                  labelText:
                                      'Masukkan Password untuk Konfirmasi',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                obscureText: true,
                                enabled: state.status != AuthStatus.loading,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Masukkan password Anda untuk konfirmasi';
                                  }
                                  return null;
                                },
                              ),

                              if (state.errorMessage != null) ...[
                                const SizedBox(height: AppSizes.marginM),
                                Container(
                                  padding: const EdgeInsets.all(
                                    AppSizes.paddingS,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.error.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: AppColors.error,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          state.errorMessage!,
                                          style: TextStyle(
                                            color: AppColors.error,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              if (state.status == AuthStatus.loading) ...[
                                const SizedBox(height: AppSizes.marginM),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Menghapus akun...',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed:
                                state.status == AuthStatus.loading
                                    ? null
                                    : () => Navigator.pop(dialogContext),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed:
                                state.status == AuthStatus.loading
                                    ? null
                                    : () async {
                                      if (formKey.currentState!.validate()) {
                                        final success = await context
                                            .read<AuthCubit>()
                                            .deleteAccount(
                                              password: passwordController.text,
                                            );

                                        if (success && dialogContext.mounted) {
                                          Navigator.pop(dialogContext);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Akun berhasil dihapus',
                                              ),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                          // The auth cubit will handle logout automatically
                                        }
                                      }
                                    },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                            child: const Text('Hapus Akun'),
                          ),
                        ],
                      ),
                ),
          ),
    );
  }
}
