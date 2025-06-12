import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      surface: Colors.white,
      background: Colors.white,
      onSurface: Colors.black87,
    ),
    useMaterial3: true,
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    colorScheme: const ColorScheme.dark(
      primary: Colors.blue,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      onSurface: Colors.white,
    ),
    useMaterial3: true,
  );
}
