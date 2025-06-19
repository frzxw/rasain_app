import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rasain_app/features/auth/register_screen.dart';
import 'package:rasain_app/features/home/home_screen.dart';
import 'package:rasain_app/cubits/auth/auth_cubit.dart';
import 'package:rasain_app/cubits/auth/auth_state.dart' as auth_state;
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  final void Function()? onLoginSuccess;
  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final success = await context.read<AuthCubit>().signIn(
          _email,
          _password,
        );

        if (success) {
          if (widget.onLoginSuccess != null) {
            widget.onLoginSuccess!();
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to log in: $e')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signInWithOAuth(OAuthProvider.google);
      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to login with Google: $e')),
      );
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
    return BlocListener<AuthCubit, auth_state.AuthState>(
      listener: (context, state) {
        if (state.status == auth_state.AuthStatus.error) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<AuthCubit, auth_state.AuthState>(
            builder: (context, state) {
              final isLoading =
                  (state.status == auth_state.AuthStatus.loading) || _isLoading;

              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      enabled: !isLoading,
                      validator:
                          (value) =>
                              value!.isEmpty ? 'Please enter your email' : null,
                      onChanged: (value) => _email = value,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      enabled: !isLoading,
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? 'Please enter your password'
                                  : null,
                      onChanged: (value) => _password = value,
                    ),
                    const SizedBox(height: 20),

                    // Show error message if any
                    if (state.status == auth_state.AuthStatus.error) ...[
                      if (state.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],

                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: _login,
                          child: const Text('Login'),
                        ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _loginWithGoogle,
                      icon: Image.asset(
                        'assets/images/google_logo.png',
                        height: 24,
                        width: 24,
                      ),
                      label: const Text('Login with Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const RegisterScreen(),
                                  ),
                                );
                              },
                      child: const Text('Don\'t have an account? Register'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
