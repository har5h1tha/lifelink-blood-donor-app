import 'package:flutter/material.dart';

class ThemeViewModel extends ChangeNotifier {
  bool isDarkMode = false;

  void toggleTheme(bool value) {
    isDarkMode = value;
    notifyListeners();
  }
}
