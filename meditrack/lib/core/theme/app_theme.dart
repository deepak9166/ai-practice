import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// App Theme Configuration
///
/// Centralized theme configuration for the application.
/// Provides light and dark theme definitions.
class AppTheme {
  AppTheme._();

  /// Common Colors
  static const Color dividerColor = Color(0xFFF3F3F3);
  static const Color titleTextColor = Color(0xFFF101218);
  static const Color descriptionTextColor = Color(0xFFF575757);
  static const Color lightThemeColro = Color(0xFFB896E8);
  static const Color primaryThemeColor = Color(0xFF996FD6);
  static const Color backgroundContainer = Color.fromRGBO(208, 201, 234, 0.3);

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: AppFont.redHatDisplay,
      scaffoldBackgroundColor: Colors.white,
      useMaterial3: true,
      primaryColor: Color(0XFF996FD6),
      secondaryHeaderColor: Color.fromRGBO(
        208,
        201,
        234,
        0.3,
      ), //rgba(208, 201, 234, 0.3)
      colorScheme: ColorScheme.fromSeed(
        primary: Color(0XFF996FD6),
        secondary: Color(0xffF3F3F3),
        seedColor: const Color.from(
          alpha: 1,
          red: 0.129,
          green: 0.588,
          blue: 0.953,
        ),
        brightness: Brightness.light,
        onSecondary: Color(0XFF101218), //#101218
        onSecondaryFixedVariant: Color(0XFF575757), //#575757
        surfaceContainer: Color(0xffF3F3F3),
        surfaceBright: Color(0xff27272F),
        inverseSurface: Color(0xff996FD6),
        onPrimaryFixed: Color(0xffFFFFFF),
        outline: Color.fromRGBO(208, 201, 234, 0.3), //#F3F3F3
        surfaceContainerLow: Color(0xffF1EFF9),
        onSecondaryContainer: Color.fromRGBO(
          208,
          201,
          234,
          0.3,
        ), //#F3F3F3 // #D0C9EA4D
        onSecondaryFixed: Color(0xffD0C9EA), // #D0C9EA
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Color.fromRGBO(208, 201, 234, 0.3),
        backgroundColor: Colors.white,
        // leadingWidth: 20,
        surfaceTintColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          fontFamily: AppFont.redHatDisplay,
          color: Color(0xff101218)
        ),
        
      ),

      dividerColor: Color.fromRGBO(243, 243, 243, 1), //#F3F3F3

      dividerTheme: DividerThemeData(
        color: Color.fromRGBO(243, 243, 243, 1), //#F3F3F3
      ),

      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          fontFamily: 'RedHatDisplay',
          fontSize: 14,
          color: Color(0xff575757),
        ),
        filled: true,
        fillColor: Color.fromRGBO(208, 201, 234, 0.3),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            strokeAlign: 0,
            width: 0,
            color: Colors.transparent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            strokeAlign: 0,
            width: 0,
            color: Colors.transparent,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0XFF996FD6), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            strokeAlign: 0,
            width: 0,
            color: Colors.transparent,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(
          fontFamily: AppFont.redHatDisplay,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color.fromRGBO(208, 201, 234, 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              strokeAlign: 0,
              width: 0,
              color: Colors.transparent,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              strokeAlign: 0,
              width: 0,
              color: Colors.transparent,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0XFF996FD6), width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              strokeAlign: 0,
              width: 0,
              color: Colors.transparent,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          foregroundColor: Colors.white,
          backgroundColor: Color(0XFF996FD6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: AppFont.bricolageGrotesque,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Color.fromRGBO(208, 201, 234, 0.3)),
          ),
        ),
      ),

      textTheme: const TextTheme(
        // Display styles (for large headings)
        displayLarge: TextStyle(
          fontFamily: AppFont.redHatDisplay,
          fontSize: 57,
          fontWeight: FontWeight.w400, // Regular
          height: 1.12,
        ),

        //
        displayMedium: TextStyle(
          fontFamily: AppFont.redHatDisplay,
          fontSize: 45,
          fontWeight: FontWeight.w400,
          height: 1.16,
        ),

        /// Don't change -  35px700
        displaySmall: TextStyle(
          fontFamily: AppFont.bricolageGrotesque,
          fontSize: 35,
          fontWeight: FontWeight.bold,
          color: Color(0xff101218),
        ),

        /// Headline styles
        headlineLarge: TextStyle(
          fontFamily: AppFont.redHatDisplay,
          fontSize: 32,
          fontWeight: FontWeight.w400,
          height: 1.25,
        ),

        /// Don't change - 24px700
        headlineMedium: TextStyle(
          fontFamily: AppFont.redHatDisplay,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.29,
          color: Color(0xff101218),
        ),

        /// Don't change - 24px400
        headlineSmall: TextStyle(
          fontFamily: AppFont.redHatDisplay,
          fontSize: 24,
          fontWeight: FontWeight.w400,
          height: 1.33,
        ),

        // Title styles
        /// Don't change - 18px700
        titleLarge: TextStyle(
          fontFamily: AppFont.redHatDisplay,
          fontSize: 18,
          fontWeight: FontWeight.w700, // SemiBold
          height: 1.27,
          color: Color(0xff101218),
        ),

        /// Don't change - 16px500
        titleMedium: TextStyle(
          fontFamily: AppFont.redHatDisplay,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: Color(0xff575757),
        ),

        /// Don't change - 16px600
        titleSmall: TextStyle(
          fontFamily: AppFont.redHatDisplay,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.43,
          color: Color(0xff101218),
        ),

        /// Don't change - 16px400
        bodyLarge: TextStyle(
          fontFamily: AppFont.redHatDisplay,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: Color(0xff575757),
        ),

        /// Don't change - 14px400
        bodyMedium: TextStyle(
          fontFamily: AppFont.redHatDisplay,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.43,
          color: Color(0xff575757),
        ),

        /// Don't change - 12px500
        bodySmall: TextStyle(
          fontFamily: AppFont.redHatDisplay,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.33,
          color: Color(0xff575757),
        ),

        // Label styles (buttons, inputs, etc.)
        /// Don't change - 18px500
        labelLarge: TextStyle(
          fontFamily: AppFont.redHatDisplay,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.43,
        ),

        /// Don't change - 12px600
        labelMedium: TextStyle(
          fontFamily: AppFont.redHatDisplay,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.33,
          color: Color(0xffFFFFFF),
        ),

        /// Don't change - 10px600
        labelSmall: TextStyle(
          fontFamily: AppFont.redHatDisplay,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          height: 1.45,
          color: Color(0xff101218),
        ),
      ),
    );
  }

  /// Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[900],
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
