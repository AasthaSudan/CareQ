import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ============================================
  // PRIMARY COLORS - Purple Theme
  // ============================================
  static const Color primaryPurple = Color(0xFF7C6FDC);
  static const Color primaryLight = Color(0xFF9B8FE8);
  static const Color primaryDark = Color(0xFF5B4FB5);

  // ============================================
  // SECONDARY COLORS - Teal (Your Original)
  // ============================================
  static const Color teal = Color(0xFF44B6AF);
  static const Color tealDark = Color(0xFF2F9F94);
  static const Color tealLight = Color(0xFF60C7B9);

  // ============================================
  // ACCENT COLORS
  // ============================================
  static const Color accentPink = Color(0xFFE8A5C3);
  static const Color accentBlue = Color(0xFF6BB7E8);

  // ============================================
  // STATUS COLORS (Your Original - Perfect!)
  // ============================================
  static const Color critical = Color(0xFFEF4444);
  static const Color urgent = Color(0xFFFACC15);
  static const Color stable = Color(0xFF22C55E);

  // ============================================
  // BACKGROUND & SURFACE
  // ============================================
  static const Color scaffoldBg = Color(0xFFF8F9FE);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardShadowColor = Color(0x1A000000);  // Renamed this to avoid conflict

  // ============================================
  // TEXT COLORS
  // ============================================
  static const Color textPrimary = Color(0xFF1F1F39);
  static const Color textSecondary = Color(0xFF858597);
  static const Color textLight = Color(0xFFB8B8D2);

  // ============================================
  // GRADIENTS
  // ============================================

  /// Primary Purple Gradient (For main UI elements)
  static LinearGradient primaryGradient() => const LinearGradient(
    colors: [Color(0xFF7C6FDC), Color(0xFF9B8FE8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Teal Gradient (For secondary elements)
  static LinearGradient tealGradient() => const LinearGradient(
    colors: [Color(0xFF44B6AF), Color(0xFF60C7B9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Card Gradient (Subtle background)
  static LinearGradient cardGradient() => const LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent Gradient (Pink to Purple)
  static LinearGradient accentGradient() => const LinearGradient(
    colors: [Color(0xFFE8A5C3), Color(0xFF7C6FDC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================
  // BOX SHADOWS (as static getters, not functions)
  // ============================================

  /// Card shadow with purple tint
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryPurple.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Soft shadow for minimal elements
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// Accent shadow (for floating buttons)
  static List<BoxShadow> get accentShadow => [
    BoxShadow(
      color: accentPink.withOpacity(0.3),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  /// Main Gradient (for primary sections)
  static LinearGradient mainGradient() {
    return const LinearGradient(
      colors: [Color(0xFF7C6FDC), Color(0xFF9B8FE8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }


  /// Teal shadow
  static List<BoxShadow> get tealShadow => [
    BoxShadow(
      color: teal.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ============================================
  // MAIN THEME DATA
  // ============================================
  static ThemeData get lightTheme {
    return ThemeData(
      // Basic Setup
      scaffoldBackgroundColor: scaffoldBg,
      useMaterial3: true,
      brightness: Brightness.light,

      // Primary Color Scheme
      colorScheme: ColorScheme.light(
        primary: primaryPurple,
        secondary: teal,
        tertiary: accentPink,
        surface: cardBg,
        error: critical,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),

      // Text Theme
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),

      // ============================================
      // APP BAR THEME
      // ============================================
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ============================================
      // CARD THEME
      // ============================================
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shadowColor: cardShadowColor,  // Changed this reference
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // ============================================
      // BUTTON THEMES
      // ============================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primaryPurple.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryPurple,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPurple,
          side: BorderSide(color: primaryPurple.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // ============================================
      // INPUT DECORATION THEME
      // ============================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

        // Border Styles
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEEEEF5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: critical, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: critical, width: 2),
        ),

        // Text Styles
        labelStyle: GoogleFonts.poppins(
          color: textSecondary,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.poppins(
          color: textLight,
          fontSize: 14,
        ),
        errorStyle: GoogleFonts.poppins(
          color: critical,
          fontSize: 12,
        ),

        // Icon Styles
        prefixIconColor: primaryPurple,
        suffixIconColor: textLight,
      ),

      // ============================================
      // FLOATING ACTION BUTTON
      // ============================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // ============================================
      // BOTTOM NAVIGATION BAR
      // ============================================
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryPurple,
        unselectedItemColor: textLight,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // ============================================
      // CHIP THEME
      // ============================================
      chipTheme: ChipThemeData(
        backgroundColor: primaryPurple.withOpacity(0.1),
        labelStyle: GoogleFonts.poppins(
          color: primaryPurple,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ============================================
      // DIALOG THEME
      // ============================================
      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
      ),

      // ============================================
      // SNACKBAR THEME
      // ============================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ============================================
      // DIVIDER THEME
      // ============================================
      dividerTheme: DividerThemeData(
        color: textLight.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
