import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider with ChangeNotifier {
  static const String themeBoxName = 'app_theme_box';
  static const String themeKey = 'is_dark_mode';

  bool _isDarkMode;

  ThemeProvider() : _isDarkMode = false {
    _loadThemeFromHive();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> _loadThemeFromHive() async {
    final box = await Hive.openBox<bool>(themeBoxName);
    _isDarkMode = box.get(themeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final box = await Hive.openBox<bool>(themeBoxName);
    await box.put(themeKey, _isDarkMode);
    notifyListeners();
  }
}
