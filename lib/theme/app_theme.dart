import 'package:flutter/material.dart';

class AppTheme {
  // --- LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F0E6), // Cream
    cardColor: Colors.white,
    dividerColor: const Color(0xFFD7CCC8),
    primarySwatch: Colors.brown,

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF3E2723)), // Dark Espresso
      bodySmall: TextStyle(color: Color(0xFF5D4037)),
      titleLarge: TextStyle(
        color: Color(0xFF3E2723),
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Color(0xFF3E2723),
        fontWeight: FontWeight.w900,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFEFEBE9), // Soft Almond
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        color: Color(0xFF8D6E63),
        fontWeight: FontWeight.bold,
      ),
      hintStyle: TextStyle(color: Colors.brown.withOpacity(0.4)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),

    iconTheme: const IconThemeData(color: Color(0xFF3E2723)),
  );

  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF12100F), // Deep Charcoal
    canvasColor: const Color(0xFF1E1B1A), // For BottomSheets
    cardColor: const Color(0xFF2C2523), // Espresso Crema
    dividerColor: const Color(0xFF4E342E),
    primarySwatch: Colors.brown,

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFFEFEBE9)), // Steam White
      bodySmall: TextStyle(color: Color(0xFFBCAAA4)),
      titleLarge: TextStyle(
        color: Color(0xFFEFEBE9),
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Color(0xFFEFEBE9),
        fontWeight: FontWeight.w900,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2523), // Darker Brown
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        color: Color(0xFFBCAAA4),
        fontWeight: FontWeight.bold,
      ),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),

    iconTheme: const IconThemeData(color: Color(0xFFD7CCC8)),
  );
}
