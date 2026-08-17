import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// SalonVerse Brand Colors (Preserving exact brand palette with editorial balance)
class AppColors {
  AppColors._();

  // Core Brand Hues
  static const Color primary = Color(0xFFEC4899); // Vibrant Glow Pink
  static const Color primaryDark = Color(0xFFD92672); // Deep Rose
  static const Color primaryGradientEnd = Color(0xFFFB7185); // Soft Coral Pink
  static const Color primaryTint = Color(0xFFFDF2F6); // Soft Pink Tint
  static const Color primaryGlow = Color(0x29EC4899);

  // Light Mode Surfaces & Canvas (Editorial Warm Studio Tones)
  static const Color lightBackground = Color(0xFFF8F9FA); // Crisp Off-White Canvas
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure White Surface
  static const Color lightSurfaceSecondary = Color(0xFFF1F3F6); // Muted Group Container
  static const Color lightSurfaceTertiary = Color(0xFFE9ECEF);
  static const Color lightBorder = Color(0xFFE5E7EB); // Hairline Subtle Border
  static const Color lightBorderSubtle = Color(0xFFF0F2F5);

  // Light Mode Typography
  static const Color lightTextPrimary = Color(0xFF111827); // Deep Ink
  static const Color lightTextSecondary = Color(0xFF4B5563); // Balanced Slate
  static const Color lightTextTertiary = Color(0xFF9CA3AF); // Muted Meta
  static const Color lightTextMuted = Color(0xFFCBD5E1);

  // Dark Mode Surfaces & Canvas (Refined Obsidian Tones)
  static const Color darkBackground = Color(0xFF0C0D0E);
  static const Color darkSurface = Color(0xFF16181A);
  static const Color darkSurfaceElevated = Color(0xFF1F2226);
  static const Color darkSurfaceTertiary = Color(0xFF282B30);
  static const Color darkBorder = Color(0xFF2A2D32);
  static const Color darkBorderSubtle = Color(0xFF1D2024);

  // Dark Mode Typography
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);
  static const Color darkTextTertiary = Color(0xFF9CA3AF);
  static const Color darkTextMuted = Color(0xFF6B7280);

  // Semantic & Status
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFECFDF5);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoBg = Color(0xFFEFF6FF);

  // Shadows
  static const Color shadowLight = Color(0x08000000);
  static const Color shadowMedium = Color(0x12000000);
}

/// Spacing and Layout Constants (Human Rhythm System)
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 40;

  static const double pagePaddingH = 18;
  static const double pagePaddingV = 16;
  static const EdgeInsets page = EdgeInsets.symmetric(
    horizontal: pagePaddingH,
    vertical: pagePaddingV,
  );

  // Radii
  static const double radiusXs = 6;
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 22;
  static const double radiusFull = 999;

  // Component Specific
  static const double cardRadius = 16;
  static const double buttonRadius = 12;
  static const double buttonHeight = 48;
  static const double inputRadius = 12;
  static const double chipRadius = 20;
  static const double sheetRadius = 24;
  static const double dialogRadius = 20;

  static List<BoxShadow> softShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) return [];
    return [
      BoxShadow(
        color: Colors.black.withAlpha(8),
        blurRadius: 12,
        offset: const Offset(0, 3),
        spreadRadius: 0,
      ),
    ];
  }

  static List<BoxShadow> glowShadow(Color color, {double opacity = 0.22}) {
    return [
      BoxShadow(
        color: color.withAlpha((255 * opacity).round()),
        blurRadius: 14,
        offset: const Offset(0, 4),
        spreadRadius: -2,
      ),
    ];
  }
}

/// Brand Gradients
class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryDark = LinearGradient(
    colors: [AppColors.primaryDark, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gold = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emerald = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient cardSurface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [AppColors.darkSurface, AppColors.darkSurfaceElevated]
          : [AppColors.lightSurface, AppColors.lightSurfaceSecondary],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}

/// App Transitions
class AppPageTransitions {
  AppPageTransitions._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);

  static Widget fadeThrough(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      child: child,
    );
  }

  static Widget slideFromRight(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    return SlideTransition(position: offsetAnimation, child: child);
  }

  static Widget slideFromBottom(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    );

    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(opacity: fadeAnimation, child: child),
    );
  }
}

/// App Theme Builder
class AppThemeBuilder {
  AppThemeBuilder._();

  static ThemeData buildTheme(Brightness brightness, {dynamic accent}) {
    final isDark = brightness == Brightness.dark;
    Color primaryColor = AppColors.primary;
    if (accent is Color) {
      primaryColor = accent;
    } else if (accent is String) {
      switch (accent.toLowerCase()) {
        case 'rose':
          primaryColor = const Color(0xFFF43F5E);
          break;
        case 'purple':
          primaryColor = const Color(0xFF8B5CF6);
          break;
        case 'amber':
          primaryColor = const Color(0xFFF59E0B);
          break;
        case 'emerald':
          primaryColor = const Color(0xFF10B981);
          break;
        default:
          primaryColor = AppColors.primary;
      }
    }

    final baseTextTheme = isDark
        ? Typography.material2021().white
        : Typography.material2021().black;

    // Typography using Google Fonts with clean human hierarchy
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(baseTextTheme).copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        letterSpacing: -0.6,
        height: 1.15,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        letterSpacing: -0.4,
        height: 1.2,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        letterSpacing: -0.2,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        letterSpacing: -0.1,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        height: 1.45,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
      ),
    );

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: isDark ? const Color(0xFF32121E) : AppColors.primaryTint,
      onPrimaryContainer: isDark ? const Color(0xFFFFD8E4) : AppColors.primaryDark,
      secondary: AppColors.primaryGradientEnd,
      onSecondary: Colors.white,
      secondaryContainer: isDark ? AppColors.darkSurfaceTertiary : AppColors.lightSurfaceSecondary,
      onSecondaryContainer: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      tertiary: const Color(0xFFF59E0B),
      onTertiary: Colors.white,
      error: isDark ? const Color(0xFFF87171) : AppColors.error,
      onError: Colors.white,
      errorContainer: isDark ? const Color(0xFF450A0A) : AppColors.errorBg,
      onErrorContainer: isDark ? const Color(0xFFFCA5A5) : AppColors.error,
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      onSurface: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      surfaceContainer: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceSecondary,
      surfaceContainerHighest: isDark ? AppColors.darkSurfaceTertiary : AppColors.lightSurfaceTertiary,
      outline: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      outlineVariant: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
      shadow: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      textTheme: textTheme,
      splashColor: primaryColor.withAlpha(15),
      highlightColor: primaryColor.withAlpha(8),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          size: 22,
        ),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.sheetRadius)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.dialogRadius),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceElevated : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        ),
        prefixIconColor: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        suffixIconColor: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
