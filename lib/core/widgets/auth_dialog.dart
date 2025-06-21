import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../constants/sizes.dart';
import '../theme/colors.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';

class AuthDialog {
  static void showLoginDialog(
    BuildContext context, {
    VoidCallback? onLoginSuccess,
    String? redirectMessage,
  }) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => BlocBuilder<AuthCubit, AuthState>(
                  builder:
                      (context, state) => AlertDialog(                        title: const Text('Masuk'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Show redirect message if provided
                                if (redirectMessage != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(AppSizes.paddingS),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.primary.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: AppColors.primary,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            redirectMessage,
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.marginM),
                                ],
                                TextFormField(
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: state.status != AuthStatus.loading,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Masukkan email Anda';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
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
                                  enabled: state.status != AuthStatus.loading,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Masukkan password Anda';
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
                                        'Masuk...',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed:
                                state.status == AuthStatus.loading
                                    ? null
                                    : () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              AuthDialog.showPasswordResetDialog(
                                context,
                                emailController.text,
                              );
                            },
                            child: const Text('Lupa Password?'),
                          ),
                          ElevatedButton(
                            onPressed:
                                state.status == AuthStatus.loading
                                    ? null
                                    : () async {
                                      if (formKey.currentState!.validate()) {
                                        final success = await context
                                            .read<AuthCubit>()
                                            .signIn(
                                              emailController.text.trim(),
                                              passwordController.text,
                                            ); // Wait for the auth state to fully update
                                        await Future.delayed(
                                          const Duration(milliseconds: 200),
                                        );                                        if (success && context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('Berhasil masuk!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );

                                          // Trigger a state update for any listening widgets
                                          // This will help the upload screen to refresh
                                          await Future.delayed(
                                            const Duration(milliseconds: 100),
                                          );

                                          // Call the success callback if provided
                                          if (onLoginSuccess != null) {
                                            onLoginSuccess();
                                          }
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

  static void showRegisterDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => BlocBuilder<AuthCubit, AuthState>(
                  builder:
                      (context, state) => AlertDialog(
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
                                  enabled: state.status != AuthStatus.loading,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Masukkan nama Anda';
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
                                  enabled: state.status != AuthStatus.loading,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Masukkan email Anda';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
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
                                  enabled: state.status != AuthStatus.loading,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Masukkan kata sandi Anda';
                                    }
                                    if (value.length < 6) {
                                      return 'Kata sandi harus minimal 6 karakter';
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
                                  enabled: state.status != AuthStatus.loading,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Konfirmasi kata sandi Anda';
                                    }
                                    if (value != passwordController.text) {
                                      return 'Kata sandi tidak cocok';
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
                                        'Mendaftar...',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed:
                                state.status == AuthStatus.loading
                                    ? null
                                    : () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed:
                                state.status == AuthStatus.loading
                                    ? null
                                    : () async {
                                      if (formKey.currentState!.validate()) {
                                        await context.read<AuthCubit>().signUp(
                                          nameController.text,
                                          emailController.text.trim(),
                                          passwordController.text,
                                        ); // Check if registration was successful by examining the new state
                                        final newState =
                                            context.read<AuthCubit>().state;
                                        if (newState.status ==
                                                AuthStatus
                                                    .emailVerificationPending &&
                                            context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Pendaftaran berhasil! Silakan verifikasi email Anda.',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          // Navigate to email verification screen
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                                if (context.mounted) {
                                                  context.go(
                                                    '/email-verification',
                                                  );
                                                }
                                              });
                                        } else if (newState.status ==
                                                AuthStatus.authenticated &&
                                            context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Pendaftaran berhasil! Anda sekarang sudah masuk.',
                                              ),
                                              backgroundColor: Colors.green,
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

  static void showPasswordResetDialog(BuildContext context, String? email) {
    final TextEditingController emailController = TextEditingController(
      text: email,
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => BlocBuilder<AuthCubit, AuthState>(
                  builder:
                      (context, state) => AlertDialog(
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
                                  enabled: state.status != AuthStatus.loading,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Masukkan email Anda';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return 'Format email tidak valid';
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
                                        'Mengirim...',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed:
                                state.status == AuthStatus.loading
                                    ? null
                                    : () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed:
                                state.status == AuthStatus.loading
                                    ? null
                                    : () async {
                                      if (formKey.currentState!.validate()) {
                                        final success = await context
                                            .read<AuthCubit>()
                                            .resetPassword(
                                              emailController.text.trim(),
                                            );

                                        if (success && context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Link reset password telah dikirim ke email Anda.',
                                              ),
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
