import 'package:flutter/material.dart';

class AppTheme {
  // Darker Blue color scheme for light theme
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color accentBlue = Color(0xFF1976D2);
  
  // Cyan color scheme for dark theme
  static const Color primaryCyan = Color(0xFF00BCD4);
  static const Color darkCyan = Color(0xFF0097A7);
  static const Color lightCyan = Color(0xFF4DD0E1);
  static const Color accentCyan = Color(0xFF00E5FF);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      primary: primaryBlue,
      secondary: accentBlue,
    ),
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryBlue,
      thumbColor: primaryBlue,
      inactiveTrackColor: Colors.grey[300],
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryCyan,
      brightness: Brightness.dark,
      primary: primaryCyan,
      secondary: accentCyan,
    ),
    primaryColor: primaryCyan,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryCyan,
      foregroundColor: Colors.black,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryCyan,
      thumbColor: primaryCyan,
      inactiveTrackColor: Colors.grey[700],
    ),
  );
}