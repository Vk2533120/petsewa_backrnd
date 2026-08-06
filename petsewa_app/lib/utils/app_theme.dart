import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Custom Earth & Forest Palette
  static const Color primary = Color(0xFF354024);      // Kombu Green
  static const Color primaryDark = Color(0xFF4C3D19);  // Café Noir
  static const Color primaryLight = Color(0xFF55643B); // Muted Forest
  static const Color primarySoft = Color(0xFFE5D7C4);  // Bone Tint
  static const Color secondary = Color(0xFF889063);    // Moss Green
  static const Color secondarySoft = Color(0xFFF0E7DB);
  static const Color accentTan = Color(0xFFCFBB99);
  static const Color accentBone = Color(0xFFE5D7C4);
  static const Color accentRose = Color(0xFFB94A4A);
  static const Color accentBlue = Color(0xFF536D88);
  static const Color background = Color(0xFFF7F2EA);
  static const Color surface = Colors.white;
  static const Color surfaceSubtle = Color(0xFFEFE9DF);
  static const Color textPrimary = Color(0xFF354024);
  static const Color textDark = Color(0xFF4C3D19);
  static const Color textSecondary = Color(0xFF5C523A);
  static const Color textMuted = Color(0xFF8D8370);
}

class AppGradients {
  static const LinearGradient warmBanner = LinearGradient(
    colors: [Color(0xFF354024), Color(0xFF889063)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF354024), Color(0xFF55643B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mossGradient = LinearGradient(
    colors: [Color(0xFF889063), Color(0xFF55643B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tanGradient = LinearGradient(
    colors: [Color(0xFFCFBB99), Color(0xFFE5D7C4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ngoGradient = LinearGradient(
    colors: [Color(0xFF536D88), Color(0xFF354024)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppShadows {
  static final List<BoxShadow> softCard = [
    BoxShadow(
      color: const Color(0xFF354024).withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF354024).withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static final List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: const Color(0xFF354024).withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static final List<BoxShadow> subtle = [
    BoxShadow(
      color: const Color(0xFF354024).withOpacity(0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentBone),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentBone),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentRose),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentRose, width: 1.5),
        ),
        labelStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 14),
        hintStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
