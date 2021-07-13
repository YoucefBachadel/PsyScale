import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode;
  SharedPreferences prefs;

  ThemeProvider() {
    themeMode = ThemeMode.light;
    loadFromPrefs();
  }

  void toggleTheme(String theme) async {
    themeMode = theme == 'Light'
        ? ThemeMode.light
        : theme == 'Dark'
            ? ThemeMode.dark
            : ThemeMode.system;
    _initPrefs();
    prefs.setString('theme', theme);
    notifyListeners();
  }

  _initPrefs() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
  }

  loadFromPrefs() async {
    await _initPrefs();
    switch (prefs.getString('theme')) {
      case 'System':
        themeMode = ThemeMode.system;
        notifyListeners();
        break;
      case 'Light':
        themeMode = ThemeMode.light;
        notifyListeners();
        break;
      case 'Dark':
        themeMode = ThemeMode.dark;
        notifyListeners();
        break;
    }
  }
}

class MyTheme {
  static final darkTheme = ThemeData(
    primaryColor: Color(0xFF000a12),
    backgroundColor: Color(0xFF263238),
    scaffoldBackgroundColor: Color(0xFF4f5b62),
    accentColor: Color(0xFFab47bc),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: ColorScheme.dark(),
    fontFamily: 'Slabo',
  );

  static final lightTheme = ThemeData(
    primaryColor: Color(0xFFffffff),
    backgroundColor: Color(0xFFffffff),
    scaffoldBackgroundColor: Color(0xFFF0F2F5),
    accentColor: Color(0xFF447ffe),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: ColorScheme.light(),
    fontFamily: 'Slabo',
  );
}
