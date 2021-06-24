import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode;
  SharedPreferences prefs;

  ThemeProvider() {
    themeMode = ThemeMode.system;
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
    scaffoldBackgroundColor: Color(0xFF121212),
    backgroundColor: Color(0xFF121212),
    primaryColor: Colors.black,
    accentColor: Color(0xFFF29217),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: ColorScheme.dark(),
    fontFamily: 'Slabo',
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Color(0xFFF0F2F5),
    backgroundColor: Colors.white,
    primaryColor: Colors.white,
    accentColor: Color(0xFF00CCCC),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: ColorScheme.light(),
    fontFamily: 'Slabo',
  );
}
