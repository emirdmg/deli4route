import 'package:flutter/material.dart';

abstract final class RouteColors {
  static const ink = Color(0xFF172D35);
  static const muted = Color(0xFF627278);
  static const orange = Color(0xFFBA461E);
  static const orangeSoft = Color(0xFFFFEEE5);
  static const background = Color(0xFFF6F7F3);
  static const line = Color(0xFFE1E7E3);
  static const green = Color(0xFF28755B);
  static const greenSoft = Color(0xFFEAF4EE);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: RouteColors.orange,
    primary: RouteColors.orange,
    secondary: RouteColors.ink,
    surface: Colors.white,
    onSurface: RouteColors.ink,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  return base.copyWith(
    scaffoldBackgroundColor: RouteColors.background,
    textTheme: base.textTheme.apply(
      bodyColor: RouteColors.ink,
      displayColor: RouteColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: RouteColors.background,
      foregroundColor: RouteColors.ink,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        letterSpacing: -.5,
        color: RouteColors.ink,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: RouteColors.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: RouteColors.ink,
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: RouteColors.line),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        minimumSize: const Size(44, 44),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RouteColors.background,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: RouteColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: RouteColors.line),
      ),
    ),
    dividerTheme: const DividerThemeData(color: RouteColors.line, thickness: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: RouteColors.orange,
      linearTrackColor: RouteColors.line,
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: RouteColors.ink,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
