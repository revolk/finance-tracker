import 'package:flutter/material.dart';

class AppTheme {
  static const primary   = Color(0xFF6C63FF);
  static const secondary = Color(0xFF00D2FF);
  static const income    = Color(0xFF2ECC71);
  static const expense   = Color(0xFFFF6B6B);
  static const card      = Color(0xFF1E1E2E);
  static const surface   = Color(0xFF181825);
  static const bgDark    = Color(0xFF11111B);
  static const bgLight   = Color(0xFFF5F5F5);

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
    ),
    cardTheme: CardThemeData(
  color: card,
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: Colors.white,
    ),
    textTheme: _textTheme(Colors.white),
    inputDecorationTheme: _inputDecoration(card, Colors.white70),
    elevatedButtonTheme: _buttonTheme(),
  );

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgLight,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: Colors.white,
    ),
    cardTheme: CardThemeData(
  color: card,
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: Colors.black87,
    ),
    textTheme: _textTheme(Colors.black87),
    inputDecorationTheme: _inputDecoration(Colors.white, Colors.black54),
    elevatedButtonTheme: _buttonTheme(),
  );

  static TextTheme _textTheme(Color color) => TextTheme(
    displayLarge:  TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: color),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color),
    titleLarge:    TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color),
    titleMedium:   TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
    bodyLarge:     TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: color),
    bodyMedium:    TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: color.withOpacity(.7)),
    labelLarge:    TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
  );

  static InputDecorationTheme _inputDecoration(Color fill, Color hint) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fill,
        hintStyle: TextStyle(color: hint, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      );

  static ElevatedButtonThemeData _buttonTheme() => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    ),
  );
}