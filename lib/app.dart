import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/theme.dart';
import 'core/widgets/loading_screen.dart';
import 'routes.dart';

// Import cubits
import 'cubits/auth/auth_cubit.dart';
import 'cubits/recipe/recipe_cubit.dart';
import 'cubits/pantry/pantry_cubit.dart';
import 'cubits/notification/notification_cubit.dart';
import 'cubits/community/community_cubit.dart';

class RasainApp extends StatefulWidget {
  const RasainApp({super.key});

  @override
  State<RasainApp> createState() => _RasainAppState();
}

class _RasainAppState extends State<RasainApp> {
  bool _isLoading = true;
  String _loadingMessage = 'Memuat aplikasi...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _loadingMessage = 'Memuat autentikasi...';
      });
      await context.read<AuthCubit>().initialize();

      setState(() {
        _loadingMessage = 'Memuat resep...';
      });
      await context.read<RecipeCubit>().initialize();

      setState(() {
        _loadingMessage = 'Memuat pantry...';
      });
      await context.read<PantryCubit>().initialize();

      setState(() {
        _loadingMessage = 'Memuat notifikasi...';
      });
      await context.read<NotificationCubit>().initialize();

      setState(() {
        _loadingMessage = 'Memuat komunitas...';
      });
      await context.read<CommunityCubit>().initialize();

      // Delay sebentar untuk menampilkan loading yang smooth
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _loadingMessage = 'Terjadi kesalahan, coba lagi...';
      });
      // Retry after delay
      await Future.delayed(const Duration(seconds: 2));
      _initializeApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a simplified theme approach with only light theme
    final ThemeData lightTheme = AppTheme.getLightTheme();

    return MaterialApp.router(
      title: 'Rasain',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      routerConfig: createRouter(),
      builder: (context, child) {
        if (_isLoading) {
          return LoadingScreen(message: _loadingMessage);
        }
        return child!;
      },
    );
  }
}
