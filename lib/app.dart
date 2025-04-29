import 'package:flutter/material.dart';
import 'core/theme/theme.dart';
import 'routes.dart';

class RasainApp extends StatelessWidget {
  const RasainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Rasain',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: createRouter(),
    );
  }
}
