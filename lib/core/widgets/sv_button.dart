import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salonverse/app/theme/app_theme.dart';

enum SVButtonVariant { primary, secondary, tonal, outline, ghost, danger }

enum SVButtonSize { sm, md, lg }

class SVButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final SVButtonVariant variant;
  final SVButtonSize size;
  final IconData? icon;
  final IconData? suffixIcon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? customPadding;

  const SVButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = SVButtonVariant.primary,
    this.size = SVButtonSize.md,
    this.icon,
    this.suffixIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final double height;
    final double fontSize;
    final double iconSize;
    final EdgeInsets padding;

    switch (size) {
      case SVButtonSize.sm:
        height = 34.0;
        fontSize = 12.0;
        iconSize = 14.0;
        padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
        break;
      case SVButtonSize.md:
        height = 46.0;
        fontSize = 13.5;
        iconSize = 17.0;
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
        break;
      case SVButtonSize.lg:
        height = 54.0;
        fontSize = 15.0;
        iconSize = 19.0;
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
        break;
    }

    Color bgColor;
    Color textColor;
    Border? border;

    switch (variant) {
      case SVButtonVariant.primary:
        bgColor = AppColors.primary;
        textColor = Colors.white;
        break;
      case SVButtonVariant.secondary:
        bgColor = isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.primaryTint;
        textColor = AppColors.primary;
        break;
      case SVButtonVariant.tonal:
        bgColor = isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceSecondary;
        textColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
        border = Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        );
        break;
      case SVButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
        border = Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        );
        break;
      case SVButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary;
        break;
      case SVButtonVariant.danger:
        bgColor = AppColors.error;
        textColor = Colors.white;
        break;
    }

    final bool isDisabled = onPressed == null || isLoading;

    final content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == SVButtonVariant.secondary
                    ? AppColors.primary
                    : textColor,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ] else if (icon != null) ...[
          Icon(icon, size: iconSize, color: textColor),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.1,
            ),
          ),
        ),
        if (suffixIcon != null && !isLoading) ...[
          const SizedBox(width: 5),
          Icon(suffixIcon, size: iconSize, color: textColor),
        ],
      ],
    );

    return Opacity(
      opacity: isDisabled ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: isDisabled ? null : onPressed,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: isFullWidth ? height : null,
          constraints: isFullWidth ? null : BoxConstraints(minHeight: height),
          width: isFullWidth ? double.infinity : null,
          padding: customPadding ?? padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            border: border,
            boxShadow: variant == SVButtonVariant.primary && !isDisabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(45),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(child: content),
        ),
      ),
    );
  }
}

class SVIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final String? tooltip;

  const SVIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 38.0,
    this.iconSize = 18.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBg =
        backgroundColor ??
        (isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceSecondary);
    final defaultColor =
        color ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    Widget btn = GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: defaultBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(icon, size: iconSize, color: defaultColor),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: btn);
    }
    return btn;
  }
}
