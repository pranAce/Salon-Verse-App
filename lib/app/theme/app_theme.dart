import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color lightBackground = Color(0xFFFFF5F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFFDECEF);
  static const Color lightSurfaceTertiary = Color(0xFFFCDDEC);
  static const Color lightBorder = Color(0xFFF4EAEF);
  static const Color lightBorderSubtle = Color(0xFFFDF0F4);
  static const Color lightTextPrimary = Color(0xFF1F2333);
  static const Color lightTextSecondary = Color(0xFF8B8FA3);
  static const Color lightTextTertiary = Color(0xFFA5A9B8);

  static const Color darkBackground = Color(0xFF0F0E0D);
  static const Color darkSurface = Color(0xFF1A1816);
  static const Color darkSurfaceElevated = Color(0xFF221F1C);
  static const Color darkSurfaceTertiary = Color(0xFF2B2824);
  static const Color darkBorder = Color(0xFF332F2A);
  static const Color darkBorderSubtle = Color(0xFF272420);
  static const Color darkTextPrimary = Color(0xFFF7F5F0);
  static const Color darkTextSecondary = Color(0xFFBEB5A9);
  static const Color darkTextTertiary = Color(0xFF8A7F73);

  static const Color pink = Color(0xFFEC4899);
  static const Color pinkGradientEnd = Color(0xFFFB7185);
  static const Color pinkLight = Color(0xFFFDECEF);
  static const Color bronzePrimaryLight = Color(0xFFEC4899);
  static const Color bronzePrimaryDark = Color(0xFFFB7185);
  static const Color rosePrimaryLight = Color(0xFFEC4899);
  static const Color rosePrimaryDark = Color(0xFFFB7185);
  static const Color glowPrimaryLight = Color(0xFFEC4899);
  static const Color glowPrimaryDark = Color(0xFFFB7185);

  static const Color success = Color(0xFF2E7D32);
  static const Color successDark = Color(0xFF66BB6A);
  static const Color error = Color(0xFFC62828);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color warning = Color(0xFFE65100);
  static const Color warningDark = Color(0xFFFFB74D);

  static const Color shadowLight = Color(0x0A5C4A37);
  static const Color shadowMedium = Color(0x125C4A37);
}

class AppSpacing {
  AppSpacing._();

  static const double pagePaddingH = 24;
  static const double pagePaddingV = 20;
  static const EdgeInsets page = EdgeInsets.symmetric(
    horizontal: pagePaddingH,
    vertical: pagePaddingV,
  );

  static const double radiusXs = 8;
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;
  static const double radiusFull = 100;

  static const double cardRadius = 16;
  static const double inputRadius = 14;
  static const double buttonRadius = 14;
  static const double bottomSheetRadius = 24;
  static const double dialogRadius = 20;
  static const double chipRadius = 20;
  static const double buttonHeight = 54;
  static const double inputContentPaddingH = 18;
  static const double inputContentPaddingV = 16;

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 48;

  static List<BoxShadow> cardShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) return [];
    return [
      const BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 12,
        offset: Offset(0, 2),
        spreadRadius: 0,
      ),
    ];
  }

  static List<BoxShadow> cardShadowMedium(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) return [];
    return [
      const BoxShadow(
        color: AppColors.shadowMedium,
        blurRadius: 20,
        offset: Offset(0, 4),
        spreadRadius: 0,
      ),
    ];
  }
}

class AppGradients {
  AppGradients._();

  static LinearGradient primary(BuildContext context) {
    final theme = Theme.of(context);
    return LinearGradient(
      colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient warmSurface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [AppColors.darkSurface, AppColors.darkSurfaceElevated]
          : [AppColors.lightSurface, AppColors.lightSurfaceSecondary],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static LinearGradient glass(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: [
        isDark ? Colors.white.withAlpha(8) : Colors.white.withAlpha(140),
        isDark ? Colors.white.withAlpha(3) : Colors.white.withAlpha(50),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

class AppPageTransitions {
  AppPageTransitions._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 400);

  static Widget slideFromRight(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutExpo,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.08, 0),
        end: Offset.zero,
      ).animate(curved),
      child: FadeTransition(opacity: curved, child: child),
    );
  }

  static Widget fadeThrough(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }

  static Widget slideFromBottom(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutExpo,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(curved),
      child: FadeTransition(opacity: curved, child: child),
    );
  }
}

InputDecorationTheme buildInputDecorationTheme(ColorScheme colorScheme) {
  final isDark = colorScheme.brightness == Brightness.dark;
  final fillColor = isDark
      ? AppColors.darkSurfaceElevated
      : AppColors.lightSurfaceSecondary;
  final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

  return InputDecorationTheme(
    filled: true,
    fillColor: fillColor,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.inputContentPaddingH,
      vertical: AppSpacing.inputContentPaddingV,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
      borderSide: BorderSide(color: borderColor, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
      borderSide: BorderSide(
        color: borderColor.withAlpha(isDark ? 80 : 120),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
      borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
      borderSide: BorderSide(color: colorScheme.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
      borderSide: BorderSide(color: colorScheme.error, width: 1.5),
    ),
    labelStyle: TextStyle(
      color: colorScheme.onSurfaceVariant,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    floatingLabelStyle: TextStyle(
      color: colorScheme.primary,
      fontWeight: FontWeight.w600,
    ),
    hintStyle: TextStyle(
      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
  );
}

ElevatedButtonThemeData buildElevatedButtonTheme(ColorScheme colorScheme) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(64, AppSpacing.buttonHeight),
      elevation: 0,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
  );
}

OutlinedButtonThemeData buildOutlinedButtonTheme(ColorScheme colorScheme) {
  final isDark = colorScheme.brightness == Brightness.dark;
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
      side: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
  );
}

FilledButtonThemeData buildFilledButtonTheme() {
  return FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
  );
}

class AppThemeBuilder {
  AppThemeBuilder._();

  static const Map<String, Map<String, Color>> accents = {
    "salonverse": {
      "light": Color(0xFFEC4899),
      "dark": Color(0xFFFB7185),
      "secondary_light": Color(0xFFEC4E7F),
      "secondary_dark": Color(0xFFFB7185),
    },
    "glow_pink": {
      "light": Color(0xFFEC4899),
      "dark": Color(0xFFFB7185),
      "secondary_light": Color(0xFFEC4E7F),
      "secondary_dark": Color(0xFFFB7185),
    },
    "bronze": {
      "light": Color(0xFFEC4899),
      "dark": Color(0xFFFB7185),
      "secondary_light": Color(0xFFEC4E7F),
      "secondary_dark": Color(0xFFFB7185),
    },
    "rose_gold": {
      "light": Color(0xFFEC4899),
      "dark": Color(0xFFFB7185),
      "secondary_light": Color(0xFFEC4E7F),
      "secondary_dark": Color(0xFFFB7185),
    },
    "glow_gold": {
      "light": Color(0xFFEC4899),
      "dark": Color(0xFFFB7185),
      "secondary_light": Color(0xFFEC4E7F),
      "secondary_dark": Color(0xFFFB7185),
    },
  };

  static String normalizeAccent(String accent) {
    if (!accents.containsKey(accent)) return "salonverse";
    return accent;
  }

  static ColorScheme _getColorScheme(String accent, Brightness brightness) {
    accent = normalizeAccent(accent);
    final isDark = brightness == Brightness.dark;
    final accentMap = accents[accent]!;

    final primary = isDark ? accentMap["dark"]! : accentMap["light"]!;
    final secondary = isDark
        ? accentMap["secondary_dark"]!
        : accentMap["secondary_light"]!;

    if (isDark) {
      return ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: AppColors.darkBackground,
        surfaceContainerLowest: AppColors.darkBackground,
        surfaceContainerLow: AppColors.darkSurface,
        surfaceContainer: AppColors.darkSurfaceElevated,
        surfaceContainerHigh: AppColors.darkSurfaceTertiary,
        onSurface: AppColors.darkTextPrimary,
        onSurfaceVariant: AppColors.darkTextSecondary,
        outline: AppColors.darkBorder,
        error: AppColors.errorDark,
        onError: Colors.black,
      );
    } else {
      return ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: AppColors.lightBackground,
        surfaceContainerLowest: AppColors.lightSurface,
        surfaceContainerLow: AppColors.lightSurface,
        surfaceContainer: AppColors.lightSurfaceSecondary,
        surfaceContainerHigh: AppColors.lightSurfaceTertiary,
        onSurface: AppColors.lightTextPrimary,
        onSurfaceVariant: AppColors.lightTextSecondary,
        outline: AppColors.lightBorder,
        error: AppColors.error,
        onError: Colors.white,
      );
    }
  }

  static ThemeData buildTheme(
    Brightness brightness, {
    String accent = "salonverse",
  }) {
    final colorScheme = _getColorScheme(accent, brightness);
    final isDark = brightness == Brightness.dark;
    final scaffoldColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final navBarColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final baseTextTheme = GoogleFonts.outfitTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    final titleFont = GoogleFonts.outfit();

    final customTextTheme = baseTextTheme.copyWith(
      displayLarge: titleFont.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        height: 1.1,
        color: colorScheme.onSurface,
      ),
      displayMedium: titleFont.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.15,
        color: colorScheme.onSurface,
      ),
      headlineLarge: titleFont.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.2,
        color: colorScheme.onSurface,
      ),
      headlineMedium: titleFont.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.25,
        color: colorScheme.onSurface,
      ),
      headlineSmall: titleFont.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.3,
        color: colorScheme.onSurface,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.3,
        color: colorScheme.onSurface,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.35,
        color: colorScheme.onSurface,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.4,
        color: colorScheme.onSurface,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        height: 1.5,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
        letterSpacing: -0.05,
        height: 1.5,
        color: isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: isDark
            ? AppColors.darkTextTertiary
            : AppColors.lightTextTertiary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: customTextTheme,
      scaffoldBackgroundColor: scaffoldColor,
      canvasColor: scaffoldColor,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(AppSpacing.cardRadius),
          ),
          side: BorderSide(
            color: colorScheme.outline.withAlpha(isDark ? 60 : 80),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scaffoldColor,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        titleTextStyle: customTextTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 68,
        backgroundColor: navBarColor,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withAlpha(isDark ? 25 : 15),
        labelTextStyle: WidgetStatePropertyAll(
          customTextTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            fontSize: 11,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        elevation: 0,
        pressElevation: 0,
        backgroundColor: colorScheme.primary.withAlpha(12),
        labelStyle: customTextTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? AppColors.darkSurfaceElevated
            : colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: isDark
              ? AppColors.darkTextPrimary
              : colorScheme.onInverseSurface,
          fontWeight: FontWeight.w500,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
        ),
      ),
      inputDecorationTheme: buildInputDecorationTheme(colorScheme),
      elevatedButtonTheme: buildElevatedButtonTheme(colorScheme),
      outlinedButtonTheme: buildOutlinedButtonTheme(colorScheme),
      filledButtonTheme: buildFilledButtonTheme(),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.bottomSheetRadius),
          ),
        ),
        showDragHandle: true,
        backgroundColor: cardColor,
        modalBackgroundColor: cardColor,
        elevation: 0,
        dragHandleColor: colorScheme.outline,
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.dialogRadius),
        ),
        titleTextStyle: customTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primary.withAlpha(20),
        circularTrackColor: colorScheme.primary.withAlpha(20),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withAlpha(isDark ? 40 : 60),
        thickness: 1,
        space: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceElevated
              : colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color: isDark
              ? AppColors.darkTextPrimary
              : colorScheme.onInverseSurface,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
