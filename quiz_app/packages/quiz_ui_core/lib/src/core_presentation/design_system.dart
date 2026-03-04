import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_domain/quiz_domain.dart';

class AppColors {
  // Midnight Oasis Palette
  static const Color background = Color(0xFF0F172A); // Deep Slate
  static const Color surface = Color(0xFF1E293B); // Slate
  static const Color primary = Color(0xFF8B5CF6); // Electric Purple
  static const Color secondary = Color(0xFF2DD4BF); // Cyber Teal
  static const Color accent = Color(0xFFF472B6); // Neon Pink

  // Neutral Colors (Dark Mode)
  static const Color textPrimary = Color(0xFFF8FAFC); // Silver White
  static const Color textSecondary = Color(0xFFCBD5E1); // Muted Silver
  static const Color border = Color(0xFF334155); // Darker Slate
  static const Color cardColor = surface;

  // States
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF064E3B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFF7F1D1D);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFF78350F);

  // Gamification & Premium
  static const Color streakFire = Color(0xFFFF5D00);
  static const Color glass = Color(0x33FFFFFF);
  static const Color glassBorder = Color(0x4DFFFFFF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient midnightGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient streakGradient = LinearGradient(
    colors: [streakFire, Color(0xFFFF9E00)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static const LinearGradient premiumGold = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient difficultyEasy = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient difficultyMedium = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient difficultyHard = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.3),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> get accentGlow => [
        BoxShadow(
          color: accent.withValues(alpha: 0.3),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ];
}

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 800);
  static const Duration epic = Duration(milliseconds: 1200);

  static const Curve curve = Curves.elasticOut; // More iOS/Bouncy feel
  static const Curve springCurve = Curves.easeOutBack;
  static const Curve standardCurve = Curves.easeInOutCubic;
}

class AppTypography {
  static TextStyle get h1 => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get h3 => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get h4 => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 18,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 16,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textSecondary,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );
}

class AppTheme {
  static ThemeData getTheme(OrganizationBrandingEntity branding) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: branding.primaryColor,
        secondary: branding.secondaryColor,
        tertiary: branding.accentColor,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme:
          GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        labelLarge: AppTypography.label,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.h3,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: branding.primaryColor.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
            AppTypography.label.copyWith(color: AppColors.textPrimary)),
      ),
    );
  }
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Navigation Metrics
  static const double bottomNavBarHeight = 85.0;
  static const double bottomNavBarPadding = 110.0; // Height + breathing room

  // Header Metrics
  static const double headerHeightCompact = 60.0;
  static const double headerHeightExpanded =
      180.0; // Increased to 180 for better fit

  static double getHeaderHeight(BuildContext context, {bool expanded = false}) {
    final double baseHeight =
        expanded ? headerHeightExpanded : headerHeightCompact;
    return baseHeight + MediaQuery.of(context).padding.top;
  }
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double full = 999.0;
}
