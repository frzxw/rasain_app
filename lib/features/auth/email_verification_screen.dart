import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  void _goToLogin() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Auto-navigate to home when email is verified
        if (state.status == AuthStatus.authenticated) {
          print(
            'EmailVerificationScreen: User authenticated, navigating to home',
          );
          // Show success message before navigating
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Email berhasil diverifikasi! Selamat datang!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Navigate after a short delay to let user see the message
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              context.go('/');
            }
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verifikasi Email'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, size: 100, color: Colors.blue),
              const SizedBox(height: 32),
              const Text(
                'Periksa Email Anda',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Kami telah mengirimkan link verifikasi ke email Anda.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Langkah-langkah:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Buka email Anda (periksa inbox dan folder spam)\n'
                      '2. Klik link "Confirm your email"\n'
                      '3. Anda akan otomatis login dan diarahkan ke aplikasi\n'
                      '4. Jika tidak otomatis, tekan tombol "Coba Login" di bawah',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _goToLogin,
                      icon: const Icon(Icons.login),
                      label: const Text('Coba Login'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Setelah Anda klik link verifikasi di email, '
                'kembali ke halaman ini dan tekan "Coba Login" untuk masuk ke akun Anda. '
                'Jika masih belum bisa, tunggu beberapa menit dan coba lagi.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
