import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  void toggleTheme(String theme) async {
    themeMode = theme == 'Light'
        ? ThemeMode.light
        : theme == 'Dark'
            ? ThemeMode.dark
            : ThemeMode.system;
    notifyListeners();
  }
}

class MyTheme {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Color(0xFF000205),
    backgroundColor: Colors.black,
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
    accentColor: Color(0xFF1777F2),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: ColorScheme.light(),
    fontFamily: 'Slabo',
  );
}
