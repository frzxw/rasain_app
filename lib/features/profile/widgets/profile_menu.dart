import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/user_profile.dart';
import '../../../services/auth_service.dart';

class ProfileMenu extends StatefulWidget {
  final UserProfile user;
  final VoidCallback onLogout;
  final Function(bool, String?, bool) onUpdateSettings;
  
  const ProfileMenu({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onUpdateSettings,
  });

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'id'; // Default to Indonesian
  
  final List<Map<String, dynamic>> _availableLanguages = [
    {'code': 'id', 'name': 'Bahasa Indonesia'},
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'zh', 'name': 'Chinese'},
  ];

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = widget.user.isNotificationsEnabled;
    _selectedLanguage = widget.user.language ?? 'id'; // Default to Indonesian
  }

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
          
          const SizedBox(height: AppSizes.marginS),
          
          // General section card
          _buildSectionCard(
            title: 'Umum',
            children: [
              // Notifications
              _buildSettingsToggle(
                title: 'Notifikasi',
                subtitle: 'Terima rekomendasi resep dan pembaruan',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  widget.onUpdateSettings(_notificationsEnabled, _selectedLanguage, false);
                },
              ),
              
              _buildDivider(),
              
              // Language Setting
              _buildLanguageSetting(),
            ],
          ),
          
          const SizedBox(height: AppSizes.marginL),
          
          // Account Management Section Card
          _buildSectionCard(
            title: 'Akun',
            children: [
              // Change Password
              _buildMenuButton(
                icon: Icons.lock_outline,
                title: 'Ubah Password',
                onTap: () => _showChangePasswordDialog(context),
              ),
              
              _buildDivider(),
              
              // Logout
              _buildMenuButton(
                icon: Icons.logout,
                title: 'Keluar',
                onTap: _confirmLogout,
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
        side: BorderSide(
          color: AppColors.border,
          width: 0.5,
        ),
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

  Widget _buildSettingsToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSetting() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bahasa',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Pilih bahasa yang Anda inginkan',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: DropdownButton<String>(
              value: _selectedLanguage,
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              underline: const SizedBox.shrink(),
              elevation: 4,
              isDense: true,
              borderRadius: BorderRadius.circular(8),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                  widget.onUpdateSettings(_notificationsEnabled, _selectedLanguage, false);
                }
              },
              items: _availableLanguages.map<DropdownMenuItem<String>>((Map<String, dynamic> language) {
                return DropdownMenuItem<String>(
                  value: language['code'],
                  child: Text(language['name']),
                );
              }).toList(),
            ),
          ),
        ],
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
  // Rest of the dialog methods remain the same
  void _confirmLogout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer<AuthService>(
        builder: (context, authService, _) => AlertDialog(
          title: const Text('Keluar'),
          content: authService.isLoading 
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 16),
                  Text('Keluar...'),
                ],
              )
            : const Text('Apakah Anda yakin ingin keluar?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: authService.isLoading ? [] : [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),            TextButton(
              onPressed: () {
                widget.onLogout();
                Navigator.pop(context);
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
  // Keep existing password and account deletion dialog methods
  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Consumer<AuthService>(
          builder: (context, authService, _) => AlertDialog(
            title: const Text('Ubah Password'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Current Password
                  TextFormField(
                    controller: currentPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Password Saat Ini',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    enabled: !authService.isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan password saat ini';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: AppSizes.marginM),
                  
                  // New Password
                  TextFormField(
                    controller: newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Password Baru',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    enabled: !authService.isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan password baru';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: AppSizes.marginM),
                  
                  // Confirm New Password
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    enabled: !authService.isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi password baru Anda';
                      }
                      if (value != newPasswordController.text) {
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
                        Text('Mengubah password...', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ],
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
                    final success = await authService.changePassword(
                      currentPasswordController.text,
                      newPasswordController.text,
                    );
                    
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password berhasil diubah'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Ubah Password'),
              ),
            ],
          ),
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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Consumer<AuthService>(
          builder: (context, authService, _) => AlertDialog(
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
                      labelText: 'Masukkan Password untuk Konfirmasi',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    enabled: !authService.isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan password Anda untuk konfirmasi';
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
                        Text('Menghapus akun...', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: authService.isLoading ? null : () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: authService.isLoading ? null : () async {
                  if (formKey.currentState!.validate()) {
                    final success = await authService.deleteAccount(passwordController.text);
                    
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Akun berhasil dihapus'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      // The auth service will handle logout automatically
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
