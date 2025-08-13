// 📄 lib/theme/theme_notifier.dart

import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  bool get isDark => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
