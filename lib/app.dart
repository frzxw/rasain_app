import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme.dart';
import 'routes.dart';
import 'services/services_initializer.dart';

class RasainApp extends StatelessWidget {
  const RasainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ServicesInitializer.getProviders(),
      child: Builder(
        builder: (context) {
          // Initialize services with Indonesian mock data
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ServicesInitializer.initializeServices(context);
          });
          
          return MaterialApp.router(
            title: 'Rasain',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: createRouter(),
          );
        }
      ),
    );
  }
}
