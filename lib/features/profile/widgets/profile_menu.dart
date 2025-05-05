import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/user_profile.dart';
import '../../../core/widgets/custom_button.dart';

class ProfileMenu extends StatefulWidget {
  final UserProfile user;
  final VoidCallback onLogout;
  final Function(bool, String?, bool) onUpdateSettings;
  
  const ProfileMenu({
    Key? key,
    required this.user,
    required this.onLogout,
    required this.onUpdateSettings,
  }) : super(key: key);

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'id'; // Default to Indonesian
  bool _darkModeEnabled = false;
  
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
    _darkModeEnabled = widget.user.isDarkModeEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Settings Header
          Text(
            'Pengaturan', // Changed to Indonesian
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          
          const SizedBox(height: AppSizes.marginM),
          
          // Notifications
          _buildSettingsToggle(
            title: 'Notifikasi', // Changed to Indonesian
            subtitle: 'Terima rekomendasi resep dan pembaruan', // Changed to Indonesian
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              widget.onUpdateSettings(_notificationsEnabled, _selectedLanguage, _darkModeEnabled);
            },
          ),
          
          _buildDivider(),
          
          // Language Setting
          _buildLanguageSetting(),
          
          _buildDivider(),
          
          // Dark Mode
          _buildSettingsToggle(
            title: 'Mode Gelap', // Changed to Indonesian
            subtitle: 'Gunakan tema gelap untuk aplikasi', // Changed to Indonesian
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
              widget.onUpdateSettings(_notificationsEnabled, _selectedLanguage, _darkModeEnabled);
            },
          ),
          
          _buildDivider(),
          
          // Account Management Section
          Text(
            'Akun', // Changed to Indonesian
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          
          const SizedBox(height: AppSizes.marginM),
          
          // Change Password
          _buildMenuButton(
            icon: Icons.lock_outline,
            title: 'Ubah Password', // Changed to Indonesian
            onTap: () => _showChangePasswordDialog(context),
          ),
          
          // Logout
          _buildMenuButton(
            icon: Icons.logout,
            title: 'Keluar', // Changed to Indonesian
            onTap: _confirmLogout,
            iconColor: AppColors.error,
            textColor: AppColors.error,
          ),
          
          // Delete Account
          _buildMenuButton(
            icon: Icons.delete_outline,
            title: 'Hapus Akun', // Changed to Indonesian
            onTap: () => _showDeleteAccountDialog(context),
            iconColor: AppColors.error,
            textColor: AppColors.error,
          ),
          
          const SizedBox(height: AppSizes.marginL),
          
          // App Info
          Center(
<<<<<<< Updated upstream
            child: Text(
              'Rasain v1.0.0',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
=======
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
>>>>>>> Stashed changes
            ),
          ),
        ],
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
                  style: Theme.of(context).textTheme.titleMedium,
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
                  'Bahasa', // Changed to Indonesian
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Pilih bahasa yang Anda inginkan', // Changed to Indonesian
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: _selectedLanguage,
            icon: const Icon(Icons.arrow_drop_down),
            underline: const SizedBox.shrink(),
            elevation: 4,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedLanguage = newValue;
                });
                widget.onUpdateSettings(_notificationsEnabled, _selectedLanguage, _darkModeEnabled);
              }
            },
            items: _availableLanguages.map<DropdownMenuItem<String>>((Map<String, dynamic> language) {
              return DropdownMenuItem<String>(
                value: language['code'],
                child: Text(language['name']),
              );
            }).toList(),
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
            Icon(
              icon,
              color: iconColor ?? AppColors.textPrimary,
              size: AppSizes.iconM,
            ),
            const SizedBox(width: AppSizes.marginM),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: textColor ?? AppColors.textPrimary,
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
      thickness: 1,
      color: AppColors.divider,
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'), // Changed to Indonesian
        content: const Text('Apakah Anda yakin ingin keluar?'), // Changed to Indonesian
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'), // Changed to Indonesian
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Keluar'), // Changed to Indonesian
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Password'), // Changed to Indonesian
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current Password
              TextFormField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Password Saat Ini', // Changed to Indonesian
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan password saat ini'; // Changed to Indonesian
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSizes.marginM),
              
              // New Password
              TextFormField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Password Baru', // Changed to Indonesian
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan password baru'; // Changed to Indonesian
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter'; // Changed to Indonesian
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSizes.marginM),
              
              // Confirm New Password
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password Baru', // Changed to Indonesian
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password baru Anda'; // Changed to Indonesian
                  }
                  if (value != newPasswordController.text) {
                    return 'Password tidak cocok'; // Changed to Indonesian
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'), // Changed to Indonesian
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Password change logic would be implemented here
                Navigator.pop(context);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password berhasil diubah'), // Changed to Indonesian
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Ubah Password'), // Changed to Indonesian
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun'), // Changed to Indonesian
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tindakan ini tidak dapat dibatalkan. Semua data Anda akan dihapus secara permanen.', // Changed to Indonesian
                style: TextStyle(color: AppColors.error),
              ),
              
              const SizedBox(height: AppSizes.marginM),
              
              // Password Confirmation
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Masukkan Password untuk Konfirmasi', // Changed to Indonesian
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan password Anda untuk konfirmasi'; // Changed to Indonesian
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'), // Changed to Indonesian
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Account deletion logic would be implemented here
                Navigator.pop(context);
                widget.onLogout(); // Log out after deletion
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Hapus Akun'), // Changed to Indonesian
          ),
        ],
      ),
    );
  }
}
