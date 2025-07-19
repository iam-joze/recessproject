import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  // Define your primary and accent colors
  static const Color primaryColor = Color(0xFF4CAF50); // A nice green
  static const Color accentColor = Color(0xFFFFC107); // A warm yellow
  static const Color textColor = Color(0xFF333333);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF555555);

  // Define primaryMaterialColor
  static const MaterialColor primaryMaterialColor = MaterialColor(
    _primaryColorValue,
    <int, Color>{
      50: Color(0xFFE8F5E9),
      100: Color(0xFFC8E6C9),
      200: Color(0xFFA5D6A7),
      300: Color(0xFF81C784),
      400: Color(0xFF66BB6A),
      500: Color(_primaryColorValue), // Primary color value
      600: Color(0xFF43A047),
      700: Color(0xFF388E3C),
      800: Color(0xFF2E7D32),
      900: Color(0xFF1B5E20),
    },
  );
  static const int _primaryColorValue = 0xFF4CAF50; // Use your primaryColor hex value here

  // Define your text themes using Google Fonts
  static TextTheme appTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.poppins(
        textStyle: base.displayLarge?.copyWith(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      displayMedium: GoogleFonts.poppins(
        textStyle: base.displayMedium?.copyWith(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      headlineLarge: GoogleFonts.poppins(
        textStyle: base.headlineLarge?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      headlineMedium: GoogleFonts.poppins(
        textStyle: base.headlineMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      titleLarge: GoogleFonts.poppins(
        textStyle: base.titleLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      bodyLarge: GoogleFonts.openSans(
        textStyle: base.bodyLarge?.copyWith(
          fontSize: 16,
          color: textColor,
        ),
      ),
      bodyMedium: GoogleFonts.openSans(
        textStyle: base.bodyMedium?.copyWith(
          fontSize: 14,
          color: textColor,
        ),
      ),
      labelLarge: GoogleFonts.openSans(
        textStyle: base.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white, // For buttons
        ),
      ),
      // Add more text styles as needed
    );
  }

  // Define the overall app theme
  static ThemeData appTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightGrey,
      colorScheme: base.colorScheme.copyWith(
        primary: primaryColor,
        secondary: accentColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      textTheme: appTextTheme(base.textTheme),
      buttonTheme: base.buttonTheme.copyWith(
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // Button background color
          foregroundColor: Colors.white, // Text color
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: appTextTheme(base.textTheme).labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: accentColor, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: GoogleFonts.openSans(color: darkGrey),
      ),
    );
  }
}