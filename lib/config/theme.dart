import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primaryLight = Color(0xFF1E88E5);
  static const Color _primaryDark = Color(0xFF1565C0);
  static const Color _secondaryLight = Color(0xFF43A047);
  static const Color _secondaryDark = Color(0xFF2E7D32);
  static const Color _backgroundLight = Color(0xFFFFFFFF);
  static const Color _backgroundDark = Color(0xFF121212);
  static const Color _surfaceLight = Color(0xFFF5F5F5);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _errorLight = Color(0xFFD32F2F);
  static const Color _errorDark = Color(0xFFEF5350);
  static const Color _onPrimaryLight = Color(0xFFFFFFFF);
  static const Color _onPrimaryDark = Color(0xFFFFFFFF);
  static const Color _onSecondaryLight = Color(0xFF000000);
  static const Color _onSecondaryDark = Color(0xFF000000);
  static const Color _onBackgroundLight = Color(0xFF000000);
  static const Color _onBackgroundDark = Color(0xFFFFFFFF);
  static const Color _onSurfaceLight = Color(0xFF000000);
  static const Color _onSurfaceDark = Color(0xFFFFFFFF);
  static const Color _onErrorLight = Color(0xFFFFFFFF);
  static const Color _onErrorDark = Color(0xFF000000);

  static TextTheme _buildTextTheme(Color color) {
    return TextTheme(
      displayLarge: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 96,
          fontWeight: FontWeight.w300,
          color: color),
      displayMedium: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 60,
          fontWeight: FontWeight.w300,
          color: color),
      displaySmall: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 48,
          fontWeight: FontWeight.w400,
          color: color),
      headlineMedium: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 34,
          fontWeight: FontWeight.w400,
          color: color),
      headlineSmall: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: color),
      titleLarge: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: color),
      titleMedium: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: color),
      titleSmall: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color),
      bodyLarge: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: color),
      bodyMedium: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: color),
      labelLarge: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color),
      bodySmall: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: color),
      labelSmall: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: color),
    );
  }

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: _primaryLight,
      primaryColorDark: _primaryDark,
      secondaryHeaderColor: _secondaryLight,
      scaffoldBackgroundColor: _backgroundLight,
      appBarTheme: const AppBarTheme(
        color: _primaryLight,
        iconTheme: IconThemeData(color: _onPrimaryLight),
      ),
      textTheme: _buildTextTheme(_onBackgroundLight),
      primaryTextTheme: _buildTextTheme(_onPrimaryLight),
      colorScheme: const ColorScheme.light(
        primary: _primaryLight,
        primaryContainer: _primaryDark,
        secondary: _secondaryLight,
        secondaryContainer: _secondaryDark,
        surface: _surfaceLight,
        background: _backgroundLight,
        error: _errorLight,
        onPrimary: _onPrimaryLight,
        onSecondary: _onSecondaryLight,
        onSurface: _onSurfaceLight,
        onBackground: _onBackgroundLight,
        onError: _onErrorLight,
        brightness: Brightness.light,
      ).copyWith(error: _errorLight).copyWith(background: _backgroundLight),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: _primaryDark,
      primaryColorDark: _primaryLight,
      secondaryHeaderColor: _secondaryDark,
      scaffoldBackgroundColor: _backgroundDark,
      appBarTheme: const AppBarTheme(
        color: _primaryDark,
        iconTheme: IconThemeData(color: _onPrimaryDark),
      ),
      textTheme: _buildTextTheme(_onBackgroundDark),
      primaryTextTheme: _buildTextTheme(_onPrimaryDark),
      colorScheme: const ColorScheme.dark(
        primary: _primaryDark,
        primaryContainer: _primaryLight,
        secondary: _secondaryDark,
        secondaryContainer: _secondaryLight,
        surface: _surfaceDark,
        background: _backgroundDark,
        error: _errorDark,
        onPrimary: _onPrimaryDark,
        onSecondary: _onSecondaryDark,
        onSurface: _onSurfaceDark,
        onBackground: _onBackgroundDark,
        onError: _onErrorDark,
        brightness: Brightness.dark,
      ).copyWith(background: _backgroundDark).copyWith(error: _errorDark),
    );
  }
}
