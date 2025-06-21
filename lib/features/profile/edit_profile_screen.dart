import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/sizes.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/custom_button.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../models/user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfileScreen({super.key, required this.userProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userProfile.name;
    _bioController.text = widget.userProfile.bio ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = image.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memilih gambar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Pilih Sumber Gambar'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Kamera'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeri'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await context.read<AuthCubit>().updateProfile(
        name: _nameController.text.trim(),
        bio:
            _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
        avatarBytes: _selectedImageBytes?.toList(),
        avatarFileName: _selectedImageName,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Edit Profile'),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSizes.marginM),

                // Profile Picture Section
                _buildProfilePictureSection(),

                const SizedBox(height: AppSizes.marginXL),

                // Name Field
                _buildNameField(),

                const SizedBox(height: AppSizes.marginL),

                // Bio Field
                _buildBioField(),

                const SizedBox(height: AppSizes.marginXL * 2),

                // Save Button
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isLoading =
                        _isLoading || state.status == AuthStatus.loading;
                    return CustomButton(
                      label: 'Simpan Perubahan',
                      onPressed: isLoading ? null : _handleSaveProfile,
                      isLoading: isLoading,
                      isFullWidth: true,
                    );
                  },
                ),

                const SizedBox(height: AppSizes.marginL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        // Profile Picture
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child:
                  _selectedImageBytes != null
                      ? Image.memory(
                        _selectedImageBytes!,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      )
                      : widget.userProfile.imageUrl != null &&
                          widget.userProfile.imageUrl!.isNotEmpty
                      ? Image.network(
                        widget.userProfile.imageUrl!,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 120,
                            height: 120,
                            color: AppColors.surface,
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            color: AppColors.surface,
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      )
                      : Container(
                        width: 120,
                        height: 120,
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.textSecondary,
                        ),
                      ),
            ),
          ),
        ),

        const SizedBox(height: AppSizes.marginM),

        // Change Photo Button
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.camera_alt, color: AppColors.primary),
          label: const Text(
            'Ubah Foto Profile',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        if (_selectedImageBytes != null) ...[
          const SizedBox(height: AppSizes.marginS),
          Text(
            'Foto baru dipilih: $_selectedImageName',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  void _handleSaveProfile() {
    _saveProfile();
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nama Lengkap',
        hintText: 'Masukkan nama lengkap Anda',
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nama tidak boleh kosong';
        }
        if (value.trim().length < 2) {
          return 'Nama minimal 2 karakter';
        }
        return null;
      },
    );
  }

  Widget _buildBioField() {
    return TextFormField(
      controller: _bioController,
      decoration: const InputDecoration(
        labelText: 'Bio',
        hintText: 'Ceritakan tentang diri Anda (opsional)',
        prefixIcon: Icon(Icons.edit_note),
      ),
      maxLines: 3,
      maxLength: 200,
    );
  }
}
