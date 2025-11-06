import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  static const Color primaryPurple = Color(0xFF7C6FDC);
  static const Color primaryLight = Color(0xFF9B8FE8);
  static const Color primaryDark = Color(0xFF5B4FB5);

  static const Color teal = Color(0xFF44B6AF);
  static const Color tealDark = Color(0xFF2F9F94);
  static const Color tealLight = Color(0xFF60C7B9);

  static const Color accentPink = Color(0xFFE8A5C3);
  static const Color accentBlue = Color(0xFF6BB7E8);

  static const Color critical = Color(0xFFEF4444);
  static const Color urgent = Color(0xFFFACC15);
  static const Color stable = Color(0xFF22C55E);

  static const Color scaffoldBg = Color(0xFFF8F9FE);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardShadowColor = Color(0x1A000000);

  static const Color textPrimary = Color(0xFF1F1F39);
  static const Color textSecondary = Color(0xFF858597);
  static const Color textLight = Color(0xFFB8B8D2);

  static LinearGradient primaryGradient() => const LinearGradient(
    colors: [Color(0xFF7C6FDC), Color(0xFF9B8FE8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static TextStyle titleStyle({double size = 32, Color color = textPrimary}) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static TextStyle subtitleStyle({double size = 16, Color color = textSecondary}) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle bodyStyle({double size = 14, Color color = textPrimary}) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }

  static LinearGradient tealGradient() => const LinearGradient(
    colors: [Color(0xFF44B6AF), Color(0xFF60C7B9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient cardGradient() => const LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient accentGradient() => const LinearGradient(
    colors: [Color(0xFFE8A5C3), Color(0xFF7C6FDC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryPurple.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get accentShadow => [
    BoxShadow(
      color: accentPink.withOpacity(0.3),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  static LinearGradient mainGradient() {
    return const LinearGradient(
      colors: [Color(0xFF7C6FDC), Color(0xFF9B8FE8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static List<BoxShadow> get tealShadow => [
    BoxShadow(
      color: teal.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: scaffoldBg,
      brightness: Brightness.light,
      primaryColor: primaryPurple,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(color: textPrimary),
      ),
      colorScheme: ColorScheme.light(
        primary: primaryPurple,
        secondary: teal,
        surface: cardBg,
        error: critical,
        onPrimary: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: Colors.black,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white),
      ),
      colorScheme: ColorScheme.dark(
        primary: primaryPurple,
        secondary: teal,
        surface: Colors.black,
        error: critical,
        onPrimary: Colors.white,
      ),
    );
  }
}
