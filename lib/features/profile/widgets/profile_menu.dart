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
  String _selectedLanguage = 'en';
  bool _darkModeEnabled = false;
  
  final List<Map<String, dynamic>> _availableLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'id', 'name': 'Bahasa Indonesia'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'zh', 'name': 'Chinese'},
  ];

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = widget.user.isNotificationsEnabled;
    _selectedLanguage = widget.user.language ?? 'en';
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
            'Settings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          
          const SizedBox(height: AppSizes.marginM),
          
          // Notifications
          _buildSettingsToggle(
            title: 'Push Notifications',
            subtitle: 'Receive recipe recommendations and updates',
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
            title: 'Dark Mode',
            subtitle: 'Use dark theme for the app',
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
            'Account',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          
          const SizedBox(height: AppSizes.marginM),
          
          // Change Password
          _buildMenuButton(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () => _showChangePasswordDialog(context),
          ),
          
          // Logout
          _buildMenuButton(
            icon: Icons.logout,
            title: 'Logout',
            onTap: _confirmLogout,
            iconColor: AppColors.error,
            textColor: AppColors.error,
          ),
          
          // Delete Account
          _buildMenuButton(
            icon: Icons.delete_outline,
            title: 'Delete Account',
            onTap: () => _showDeleteAccountDialog(context),
            iconColor: AppColors.error,
            textColor: AppColors.error,
          ),
          
          const SizedBox(height: AppSizes.marginL),
          
          // App Info
          Center(
            child: Text(
              'Rasain v1.0.0',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
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
                  'Language',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Select your preferred language',
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
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
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
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current Password
              TextFormField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSizes.marginM),
              
              // New Password
              TextFormField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSizes.marginM),
              
              // Confirm New Password
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Password change logic would be implemented here
                Navigator.pop(context);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Change Password'),
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
        title: const Text('Delete Account'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This action cannot be undone. All your data will be permanently deleted.',
                style: TextStyle(color: AppColors.error),
              ),
              
              const SizedBox(height: AppSizes.marginM),
              
              // Password Confirmation
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Enter Password to Confirm',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password to confirm';
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
            child: const Text('Cancel'),
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
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
