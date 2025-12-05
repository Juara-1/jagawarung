import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Private constructor
  AppTheme._();

  // --- COLORS ---
  static const Color _lightPrimaryColor = Color(0xFF6C5CE7);
  static const Color _lightOnPrimaryColor = Colors.white;
  static const Color _lightSecondaryColor = Color(0xFFFDCB6E);
  static const Color _lightOnSecondaryColor = Color(0xFF3D3D3D);
  static const Color _lightBackgroundColor = Color(0xFFF4F5F7);
  static const Color _lightSurfaceColor = Colors.white;
  static const Color _lightErrorColor = Color(0xFFD63031);

  static const Color _darkPrimaryColor = Color(0xFF8A78F8);
  static const Color _darkOnPrimaryColor = Colors.white;
  static const Color _darkSecondaryColor = Color(0xFFFFE0A3);
  static const Color _darkOnSecondaryColor = Color(0xFF3D3D3D);
  static const Color _darkBackgroundColor = Color(0xFF121212);
  static const Color _darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color _darkErrorColor = Color(0xFFE57373);

  // --- TEXT THEME ---
  static final TextTheme _lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.plusJakartaSans(fontSize: 57, fontWeight: FontWeight.bold, color: _lightOnSecondaryColor),
    headlineLarge: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: _lightOnSecondaryColor),
    titleLarge: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: _lightOnSecondaryColor),
    bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.normal, color: _lightOnSecondaryColor),
    bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.normal, color: _lightOnSecondaryColor),
    labelLarge: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: _lightOnPrimaryColor),
  );

  static final TextTheme _darkTextTheme = _lightTextTheme.apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
    decorationColor: Colors.white,
  );

  // --- THEMES ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: _lightPrimaryColor,
      scaffoldBackgroundColor: _lightBackgroundColor,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimaryColor,
        onPrimary: _lightOnPrimaryColor,
        secondary: _lightSecondaryColor,
        onSecondary: _lightOnSecondaryColor,
        background: _lightBackgroundColor,
        surface: _lightSurfaceColor,
        error: _lightErrorColor,
        onBackground: Color(0xFF3D3D3D),
        onSurface: Color(0xFF3D3D3D),
        onError: Colors.white,
      ),
      textTheme: _lightTextTheme,
      inputDecorationTheme: _inputDecorationTheme(
        isDark: false,
        scheme: const ColorScheme.light(
          surface: _lightSurfaceColor,
          primary: _lightPrimaryColor,
          error: _lightErrorColor,
        ),
      ),
      elevatedButtonTheme: _elevatedButtonTheme(_lightPrimaryColor, _lightOnPrimaryColor),
      textButtonTheme: _textButtonTheme(_lightPrimaryColor),
      cardTheme: _cardTheme(_lightSurfaceColor),
      appBarTheme: _appBarTheme(_lightBackgroundColor, const Color(0xFF3D3D3D)),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: _darkPrimaryColor,
      scaffoldBackgroundColor: _darkBackgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimaryColor,
        onPrimary: _darkOnPrimaryColor,
        secondary: _darkSecondaryColor,
        onSecondary: _darkOnSecondaryColor,
        background: _darkBackgroundColor,
        surface: _darkSurfaceColor,
        error: _darkErrorColor,
        onBackground: Colors.white,
        onSurface: Colors.white,
        onError: Colors.black,
      ),
      textTheme: _darkTextTheme,
      inputDecorationTheme: _inputDecorationTheme(
        isDark: true,
        scheme: const ColorScheme.dark(
          surface: _darkSurfaceColor,
          primary: _darkPrimaryColor,
          error: _darkErrorColor,
        ),
      ),
      elevatedButtonTheme: _elevatedButtonTheme(_darkPrimaryColor, _darkOnPrimaryColor),
      textButtonTheme: _textButtonTheme(_darkPrimaryColor),
      cardTheme: _cardTheme(_darkSurfaceColor),
      appBarTheme: _appBarTheme(_darkBackgroundColor, Colors.white),
    );
  }

  // --- WIDGET THEMES ---
  static InputDecorationTheme _inputDecorationTheme({required bool isDark, required ColorScheme scheme}) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? scheme.surface.withOpacity(0.5) : scheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.error, width: 1),
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(Color backgroundColor, Color foregroundColor) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(Color foregroundColor) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
      ),
    );
  }

  static CardTheme _cardTheme(Color cardColor) {
    return CardTheme(
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  static AppBarTheme _appBarTheme(Color backgroundColor, Color foregroundColor) {
    return AppBarTheme(
      elevation: 0,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      centerTitle: true,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: foregroundColor,
      ),
    );
  }
}