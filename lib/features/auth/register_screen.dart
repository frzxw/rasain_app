import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final success = await context.read<AuthCubit>().signUp(
        name,
        email,
        password,
      );

      if (success && mounted) {
        // Success is handled by BlocListener
        print('RegisterScreen: Registration successful');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        print(
          'RegisterScreen: State transition - Previous: ${previous.status}, Current: ${current.status}',
        );
        return previous.status != current.status;
      },
      listener: (context, state) {
        print('RegisterScreen: State changed - Status: ${state.status}');
        if (state.status == AuthStatus.emailVerificationPending) {
          // Navigate to email verification screen
          print('RegisterScreen: Navigating to email verification screen');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/email-verification');
            }
          });
        } else if (state.status == AuthStatus.authenticated) {
          // If somehow user gets authenticated directly, go to home
          print('RegisterScreen: User authenticated, navigating to home');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/');
            }
          });
        } else if (state.status == AuthStatus.error) {
          // Show error message
          print('RegisterScreen: Error occurred - ${state.errorMessage}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Registration failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Daftar Akun')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama harus diisi';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email harus diisi';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password harus diisi';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isLoading = state.status == AuthStatus.loading;

                    return isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: _register,
                          child: const Text('Daftar'),
                        );
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Sudah punya akun? Masuk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
