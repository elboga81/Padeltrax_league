import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF1A237E); // Deep Blue
  static const Color secondaryColor = Color(0xFF7E57C2); // Purple
  static const Color lightBackgroundColor = Color(0xFFF5F5F5); // Light Grey
  static const Color darkBackgroundColor = Color(0xFF121212); // Dark Grey

  // Font Family
  static const String fontFamily =
      'Poppins'; // Replace with your font if needed

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackgroundColor,
    fontFamily: fontFamily,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.white,
      error: Colors.red,
    ),
    textTheme: _lightTextTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    cardTheme: _cardTheme,
    appBarTheme: _appBarTheme,
    bottomNavigationBarTheme: _bottomNavBarTheme.copyWith(
      backgroundColor: primaryColor,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    fontFamily: fontFamily,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.grey.shade800, // Use runtime value instead of const
      error: Colors.red,
    ),
    textTheme: _darkTextTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    cardTheme: _cardTheme.copyWith(color: Colors.grey[900]),
    appBarTheme: _appBarTheme.copyWith(
      backgroundColor: primaryColor,
    ),
    bottomNavigationBarTheme: _bottomNavBarTheme.copyWith(
      backgroundColor: Colors.grey[900],
    ),
  );

  // Text Themes
  static const TextTheme _lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    displayMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Colors.black54,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Colors.black54,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );

  static const TextTheme _darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displayMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Colors.grey,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Colors.grey,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );

  // Elevated Button Theme
  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );

  // Card Theme
  static final CardTheme _cardTheme = CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4,
    margin: const EdgeInsets.all(8),
  );

  // AppBar Theme
  static final AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: primaryColor,
    elevation: 0,
    titleTextStyle: _lightTextTheme.displayLarge,
  );

  // Bottom Navigation Bar Theme
  static const BottomNavigationBarThemeData _bottomNavBarTheme =
      BottomNavigationBarThemeData(
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white70,
  );
}
