import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: const Color(0xFFFFB74D),
      scaffoldBackgroundColor: const Color(0xFFFFF5F5),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFFFFB74D),
        secondary: const Color(0xFFFFE4E4),
        background: const Color(0xFFFFF5F5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFFFFB74D),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
      ),
    );
  }
}
