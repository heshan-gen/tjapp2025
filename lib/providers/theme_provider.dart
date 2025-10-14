import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _firstVisitKey = 'first_visit';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isFirstVisit = true;

  ThemeMode get themeMode => _themeMode;
  bool get isFirstVisit => _isFirstVisit;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  bool get isLightMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.light;
    }
    return _themeMode == ThemeMode.light;
  }

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      _themeMode = ThemeMode.values[themeIndex];
      _isFirstVisit = prefs.getBool(_firstVisitKey) ?? true;
      notifyListeners();
    } catch (e) {
      // If there's an error loading preferences, use system theme
      _themeMode = ThemeMode.system;
      _isFirstVisit = true;
    }
  }

  Future<void> setThemeMode(final ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_themeKey, mode.index);
      } catch (e) {
        // Handle error silently
        print('Error saving theme preference: $e');
      }
    }
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.system);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  IconData get themeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  String get themeTooltip {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Switch to dark mode';
      case ThemeMode.dark:
        return 'Switch to system theme';
      case ThemeMode.system:
        return 'Switch to light mode';
    }
  }

  Future<void> markFirstVisitCompleted() async {
    if (_isFirstVisit) {
      _isFirstVisit = false;
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_firstVisitKey, false);
      } catch (e) {
        // Handle error silently
        print('Error saving first visit preference: $e');
      }
    }
  }
}
