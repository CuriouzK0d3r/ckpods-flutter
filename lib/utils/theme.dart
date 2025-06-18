import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // Color palette with improved contrast for web
  static const Color primaryColor = Color(0xFF1DB954); // Spotify green
  static const Color primaryDarkColor = Color(0xFF1ED760);
  static const Color secondaryColor = Color(0xFF191414); // Dark grey
  static const Color backgroundColor =
      Color(0xFFFFFFFF); // Pure white for better contrast
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color surfaceColor = Color(0xFFFAFAFA); // Slightly off-white
  static const Color darkSurfaceColor = Color(0xFF181818);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color textPrimaryColor =
      Color(0xFF000000); // Pure black for maximum contrast
  static const Color textSecondaryColor =
      Color(0xFF666666); // Darker grey for better readability
  static const Color textDarkPrimaryColor = Color(0xFFFFFFFF);
  static const Color textDarkSecondaryColor = Color(0xFFB3B3B3);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        surface: surfaceColor,
        onSurface: textPrimaryColor,
        error: errorColor,
        onError: Colors.white,
        outline: Color(0xFFE0E0E0), // Better border contrast
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: textPrimaryColor,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        color: surfaceColor,
        shadowColor: Color(0x1A000000), // Subtle shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side:
              BorderSide(color: Color(0xFFE0E0E0), width: 0.5), // Subtle border
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          fontFamily: kIsWeb ? 'system-ui' : null,
        ),
        headlineMedium: TextStyle(
          color: textPrimaryColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.25,
          fontFamily: kIsWeb ? 'system-ui' : null,
        ),
        headlineSmall: TextStyle(
          color: textPrimaryColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: kIsWeb ? 'system-ui' : null,
        ),
        titleLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: kIsWeb ? 'system-ui' : null,
        ),
        titleMedium: TextStyle(
          color: textPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: kIsWeb ? 'system-ui' : null,
        ),
        titleSmall: TextStyle(
          color: textPrimaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: kIsWeb ? 'system-ui' : null,
        ),
        bodyLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
          fontFamily: kIsWeb ? 'system-ui' : null,
        ),
        bodyMedium: TextStyle(
          color: textPrimaryColor,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.4,
          fontFamily: kIsWeb ? 'system-ui' : null,
        ),
        bodySmall: TextStyle(
          color: textSecondaryColor,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          height: 1.3,
          fontFamily: kIsWeb ? 'system-ui' : null,
        ),
        labelLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: kIsWeb ? 'system-ui' : null,
        ),
        labelMedium: TextStyle(
          color: textSecondaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: kIsWeb ? 'system-ui' : null,
        ),
        labelSmall: TextStyle(
          color: textSecondaryColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontFamily: kIsWeb ? 'system-ui' : null,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textSecondaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textSecondaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: textSecondaryColor,
        thumbColor: primaryColor,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryDarkColor,
        onPrimary: Colors.black,
        secondary: primaryColor,
        onSecondary: Colors.black,
        surface: darkSurfaceColor,
        onSurface: textDarkPrimaryColor,
        error: errorColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: darkBackgroundColor,
        foregroundColor: textDarkPrimaryColor,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textDarkPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryDarkColor,
        unselectedItemColor: textDarkSecondaryColor,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        color: darkSurfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDarkColor,
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDarkColor,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDarkColor,
          side: const BorderSide(color: primaryDarkColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textDarkPrimaryColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textDarkPrimaryColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: textDarkPrimaryColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textDarkPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textDarkPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: textDarkPrimaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textDarkPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: textDarkPrimaryColor,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: textDarkSecondaryColor,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textDarkSecondaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textDarkSecondaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryDarkColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primaryDarkColor,
        inactiveTrackColor: textDarkSecondaryColor,
        thumbColor: primaryDarkColor,
      ),
    );
  }
}
