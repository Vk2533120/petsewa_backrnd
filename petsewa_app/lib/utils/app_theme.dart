import 'package:flutter/material.dart';

class AppColors {
  // Custom Earth & Forest Palette from User Reference
  static const Color primary = Color(0xFF354024); // Kombu Green
  static const Color primaryDark = Color(0xFF4C3D19); // Café Noir
  static const Color primaryLight = Color(0xFF55643B); // Muted Forest
  static const Color primarySoft = Color(0xFFE5D7C4); // Bone Tint

  // Secondary Accents
  static const Color secondary = Color(0xFF889063); // Moss Green
  static const Color secondarySoft = Color(0xFFF0E7DB); // Soft Moss Linen
  static const Color accentTan = Color(0xFFCFBB99); // Tan
  static const Color accentBone = Color(0xFFE5D7C4); // Bone
  static const Color accentRose = Color(0xFFB94A4A); // Muted Earth Red
  static const Color accentBlue = Color(0xFF536D88); // Muted Slate Blue

  // Backgrounds & Neutral Surfaces
  static const Color background = Color(0xFFF7F2EA); // Soft Warm Bone
  static const Color surface = Colors.white;
  static const Color surfaceSubtle = Color(0xFFEFE9DF); // Subtle Warm Linen

  // Text Colors
  static const Color textPrimary = Color(0xFF354024); // Kombu Green (Deep Text)
  static const Color textDark = Color(0xFF4C3D19); // Café Noir
  static const Color textSecondary = Color(0xFF5C523A); // Earth Slate
  static const Color textMuted = Color(0xFF8D8370); // Muted Sand
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF354024), Color(0xFF4C3D19)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmBanner = LinearGradient(
    colors: [Color(0xFF354024), Color(0xFF889063)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient mossGradient = LinearGradient(
    colors: [Color(0xFF889063), Color(0xFFCFBB99)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tanGradient = LinearGradient(
    colors: [Color(0xFFCFBB99), Color(0xFFE5D7C4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppShadows {
  static final List<BoxShadow> softCard = [
    BoxShadow(
      color: const Color(0xFF354024).withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static final List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.25),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> subtle = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Outfit',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Outfit',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
