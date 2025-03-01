import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color.fromARGB(255, 81, 142, 192), // Main brand color
    secondary: Colors.orange, // Accent color
    surface: Colors.white, // Card background
    background: Color(0xFFF5F5F5), // Light grey background
    onPrimary: Colors.white, // Text on primary color
    onSecondary: Colors.white, // Text on secondary color
    onSurface: Colors.black87, // Text on surface
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 81, 142, 192),
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  textTheme: _textTheme,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Colors.deepPurple, // Main brand color
    secondary: Colors.amber, // Accent color
    surface: Color(0xFF121212), // Dark card background
    background: Color(0xFF1E1E1E), // Dark background
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  textTheme:
      _textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
);

/// Standard text theme used in most industry apps
const TextTheme _textTheme = TextTheme(
  displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
  displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
  headlineLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  headlineMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  headlineSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
  bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
  bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
  labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
  labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
);
