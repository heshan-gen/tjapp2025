import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english,
  sinhala,
  tamil,
}

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';

  AppLanguage _currentLanguage = AppLanguage.english;

  AppLanguage get currentLanguage => _currentLanguage;

  LanguageProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageIndex = prefs.getInt(_languageKey) ?? 0;
      _currentLanguage = AppLanguage.values[languageIndex];
      notifyListeners();
    } catch (e) {
      // If there's an error loading preferences, use English
      _currentLanguage = AppLanguage.english;
    }
  }

  Future<void> setLanguage(final AppLanguage language) async {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_languageKey, language.index);
      } catch (e) {
        // Handle error silently
        print('Error saving language preference: $e');
      }
    }
  }

  void toggleLanguage() {
    if (_currentLanguage == AppLanguage.english) {
      setLanguage(AppLanguage.sinhala);
    } else if (_currentLanguage == AppLanguage.sinhala) {
      setLanguage(AppLanguage.tamil);
    } else {
      setLanguage(AppLanguage.english);
    }
  }

  String get languageCode {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'EN';
      case AppLanguage.sinhala:
        return 'සිං';
      case AppLanguage.tamil:
        return 'த';
    }
  }

  String get languageName {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.sinhala:
        return 'සිංහල';
      case AppLanguage.tamil:
        return 'தமிழ்';
    }
  }

  IconData get languageIcon {
    return Icons.language;
  }

  String get languageTooltip {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Switch to Sinhala';
      case AppLanguage.sinhala:
        return 'Switch to Tamil';
      case AppLanguage.tamil:
        return 'Switch to English';
    }
  }
}
