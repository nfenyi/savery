import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savery/app_constants/app_colors.dart';

class AppThemes {
  static final darkTheme = ThemeData(
      iconTheme: const IconThemeData(color: Colors.white),
      scaffoldBackgroundColor: Colors.grey.shade900,
      appBarTheme: const AppBarTheme(
        surfaceTintColor: Colors.black,
        backgroundColor: Colors.black,
      ),
      primaryColor: AppColors.primary,
      fontFamily: GoogleFonts.manrope(fontSize: 13).fontFamily,
      // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      dividerTheme: const DividerThemeData(color: AppColors.neutral200),
      scrollbarTheme: ScrollbarThemeData(
        crossAxisMargin: 5,
        // thickness: 5,
        thumbColor: WidgetStateProperty.all(Colors.grey[400]),

        radius: const Radius.circular(10),
      ),
      colorScheme: const ColorScheme.dark());

  static final lightTheme = ThemeData(
      iconTheme: const IconThemeData(color: Colors.black),
      scaffoldBackgroundColor: Colors.white,
      splashColor: Colors.white,
      dividerTheme: const DividerThemeData(color: AppColors.neutral200),
      // dividerColor: AppColors.neutral100,
      // hoverColor: Colors.white,
      appBarTheme: const AppBarTheme(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      fontFamily: GoogleFonts.manrope(fontSize: 13).fontFamily,
      primaryColor: AppColors.primary,
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
  ThemeProviderNotifier() : super(ThemeMode.light);
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
