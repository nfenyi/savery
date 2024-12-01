import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_constants.dart';

import '../app_constants/app_sizes.dart';

class AppThemes {
  static final darkTheme = ThemeData(
    iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.primaryDark)),
    primaryIconTheme: const IconThemeData(color: AppColors.primaryDark),
    // dropdownMenuTheme: DropdownMenuThemeData(menuStyle: MenuStyle(
    //   backgroundColor: WidgetStateProperty.resolveWith((states) {
    //     // Define your desired background color based on states (e.g., pressed, hovered)
    //     return const Color.fromARGB(255, 32, 26, 34); // Example color
    //   }),
    // )),

    dialogTheme:
        const DialogTheme(contentTextStyle: TextStyle(color: Colors.white)),
    dialogBackgroundColor: const Color.fromARGB(255, 32, 25, 33),
    colorSchemeSeed: AppColors.primaryDark,
    // textTheme: TextTheme(co),
    brightness: Brightness.dark,
    inputDecorationTheme: const InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: 1,
          color: Color.fromARGB(255, 158, 158, 158),
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSizes.bodySmallest,
        vertical: AppSizes.bodySmall,
      ),
      hintStyle: TextStyle(
        fontSize: AppSizes.bodySmaller,
        fontWeight: FontWeight.w500,
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.primaryDark),
    scaffoldBackgroundColor: const Color.fromARGB(255, 32, 26, 34),
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.black,
      backgroundColor: Color.fromARGB(255, 32, 26, 34),
    ),

    // indicatorColor: AppColors.neutral200,
    // primaryColor: AppColors.primaryDark,
    fontFamily: GoogleFonts.manrope(fontSize: 13).fontFamily,
    // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
    dividerTheme: const DividerThemeData(color: AppColors.neutral300),
    scrollbarTheme: ScrollbarThemeData(
      crossAxisMargin: 5,
      // thickness: 5,
      thumbColor: WidgetStateProperty.all(Colors.grey[400]),

      radius: const Radius.circular(10),
    ),

    // colorScheme: const ColorScheme.dark()
  );

  static final lightTheme = ThemeData(
    iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.primary)),
    primaryIconTheme: const IconThemeData(color: AppColors.primaryDark),
    inputDecorationTheme: const InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: 1,
          color: Color.fromARGB(255, 158, 158, 158),
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSizes.bodySmallest,
        vertical: AppSizes.bodySmall,
      ),
      hintStyle: TextStyle(
        fontSize: AppSizes.bodySmaller,
        fontWeight: FontWeight.w500,
      ),
    ),
    dialogBackgroundColor: Colors.white,
    colorSchemeSeed: AppColors.primary,
    brightness: Brightness.light,
    iconTheme: const IconThemeData(color: AppColors.primary),
    scaffoldBackgroundColor: Colors.white,
    splashColor: Colors.white,
    dividerTheme: const DividerThemeData(color: AppColors.neutral300),
    // dividerColor: AppColors.neutral100,
    // hoverColor: Colors.white,
    appBarTheme: const AppBarTheme(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
    ),
    fontFamily: GoogleFonts.manrope(fontSize: 13).fontFamily,
    // primaryColor: AppColors.primary,
    // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
    scrollbarTheme: ScrollbarThemeData(
      crossAxisMargin: 5,
      // thickness: 5,
      thumbColor: WidgetStateProperty.all(Colors.grey[400]),

      radius: const Radius.circular(10),
    ),
    // colorScheme: const ColorScheme.light()
  );
}

class ThemeProviderNotifier extends StateNotifier<String> {
  ThemeProviderNotifier()
      : super(Hive.box(AppBoxes.appState).get('theme', defaultValue: 'System'));
  final _appStateBox = Hive.box(AppBoxes.appState);
  // ThemeMode themeMode = ThemeMode.system;
  // ThemeMode get getThemeMode => themeMode;

  Future<void> changeTheme(String? selectedThemeMode) async {
    state = selectedThemeMode ?? 'System';
    await _appStateBox.put('theme', selectedThemeMode);
  }
}

final themeProvider = StateNotifierProvider<ThemeProviderNotifier, String>(
  (ref) => ThemeProviderNotifier(),
);
