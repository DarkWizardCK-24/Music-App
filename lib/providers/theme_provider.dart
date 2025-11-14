import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  static const String _themeModeKey = 'theme_mode';

  ThemeProvider() {
    loadThemeMode();
  }

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeModeKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeModeKey, _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;
}