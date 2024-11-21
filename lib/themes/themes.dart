import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static final darkTheme = ThemeData(
      scaffoldBackgroundColor: Colors.grey.shade900,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
      ),
      primaryColor: Colors.black,
      fontFamily: GoogleFonts.manrope(fontSize: 13).fontFamily,
      // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      scrollbarTheme: ScrollbarThemeData(
        crossAxisMargin: 5,
        // thickness: 5,
        thumbColor: WidgetStateProperty.all(Colors.grey[400]),

        radius: const Radius.circular(10),
      ),
      colorScheme: const ColorScheme.dark());

  static final lightTheme = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
      ),
      fontFamily: GoogleFonts.manrope(fontSize: 13).fontFamily,
      primaryColor: Colors.white,
      // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      scrollbarTheme: ScrollbarThemeData(
        crossAxisMargin: 5,
        // thickness: 5,
        thumbColor: WidgetStateProperty.all(Colors.grey[400]),

        radius: const Radius.circular(10),
      ),
      colorScheme: const ColorScheme.light());
}

class ThemeProviderNotifier extends StateNotifier<ThemeMode> {
  ThemeProviderNotifier() : super(ThemeMode.system);
  // ThemeMode themeMode = ThemeMode.system;
  // ThemeMode get getThemeMode => themeMode;

  void changeTheme(String? selectedThemeMode) {
    switch (selectedThemeMode) {
      case "System":
        state = ThemeMode.system;
      case "Dark":
        state = ThemeMode.dark;
      default:
        state = ThemeMode.light;
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeProviderNotifier, ThemeMode>(
  (ref) => ThemeProviderNotifier(),
);
