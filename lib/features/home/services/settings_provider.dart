import 'package:flutter/material.dart';
import 'package:salonverse/core/storage/app_storage.dart';
import 'package:salonverse/core/constants/app_constants.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _accentColor =
      "salonverse";
  int _selectedPage = 0;

  bool get isDarkMode => _isDarkMode;
  String get accentColor => _accentColor;
  int get selectedPage => _selectedPage;

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() {
    _isDarkMode = AppServices.prefs.getBool(KConstants.themeModeKey) ?? false;
    _accentColor =
        AppServices.prefs.getString(KConstants.accentColorKey) ?? "salonverse";
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    AppServices.prefs.setBool(KConstants.themeModeKey, value);
    notifyListeners();
  }

  void setAccentColor(String color) {
    _accentColor = color;
    AppServices.prefs.setString(KConstants.accentColorKey, color);
    notifyListeners();
  }

  void setPage(int value) {
    _selectedPage = value;
    notifyListeners();
  }
}
