import 'package:flutter/material.dart';
import 'package:hyper_app/config/routes.dart';
import 'package:hyper_app/config/theme.dart';

class HypertensionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hypertension Manager',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Use this to respect system theme settings
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
    );
  }
}
