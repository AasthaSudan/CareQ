import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumTheme {
  // Primary Colors (Matching Reference UI)
  static const Color primaryPurple = Color(0xFF7A5AF8);
  static const Color secondaryPurple = Color(0xFF9A4DFF);
  static const Color accentPink = Color(0xFFFF4081);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color cardWhite = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textDark = Color(0xFF2D3436);
  static const Color textGray = Color(0xFFB0BEC5);
  static const Color textLight = Color(0xFF636E72);

  // Status Colors
  static const Color successGreen = Color(0xFF28A745);
  static const Color warningOrange = Color(0xFFFFC107);
  static const Color errorRed = Color(0xFFEF5350);
  static const Color infoBlue = Color(0xFF4C83FF);

  // Gradients (Matching Reference UI)
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7A5AF8), Color(0xFF9A4DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF4C83FF), Color(0xFF6CB0F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFFF4081), Color(0xFFFF80AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF28A745), Color(0xFF5CB85C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 10),
      spreadRadius: -5,
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primaryPurple.withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(0, 8),
      spreadRadius: -3,
    ),
  ];

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  // Theme Data
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryPurple,
    scaffoldBackgroundColor: backgroundLight,

    colorScheme: const ColorScheme.light(
      primary: primaryPurple,
      secondary: secondaryPurple,
      surface: cardWhite,
      error: errorRed,
    ),

    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: textDark,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: textGray,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: textDark,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: cardWhite,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.poppins(
        color: textGray,
        fontSize: 14,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryPurple,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
  );

  // Button Text Style
  static TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Neumorphic Effect
  static BoxDecoration neumorphic({bool pressed = false}) {
    return BoxDecoration(
      color: backgroundLight,
      borderRadius: BorderRadius.circular(20),
      boxShadow: pressed
          ? [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(2, 2),
          blurRadius: 5,
        ),
      ]
          : [
        BoxShadow(
          color: Colors.white,
          offset: const Offset(-5, -5),
          blurRadius: 10,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(5, 5),
          blurRadius: 10,
        ),
      ],
    );
  }

  // Glass Effect
  static BoxDecoration glassEffect({Color? color}) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          spreadRadius: -2,
        ),
      ],
    );
  }

  // Card Decoration
  static BoxDecoration cardDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? cardWhite,
      borderRadius: BorderRadius.circular(20),
      boxShadow: cardShadow,
    );
  }

  // Gradient Button Decoration
  static BoxDecoration gradientButton(LinearGradient gradient) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: buttonShadow,
    );
  }
}