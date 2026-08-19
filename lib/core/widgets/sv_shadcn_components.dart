import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:salonverse/app/theme/app_theme.dart';

enum SvBadgeVariant {
  primary,
  purple,
  gold,
  success,
  warning,
  danger,
  outline,
  secondary,
}

class SvShadBadge extends StatelessWidget {
  final String label;
  final Widget? icon;
  final SvBadgeVariant variant;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  const SvShadBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = SvBadgeVariant.primary,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.fontSize = 11.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg;
    Color fg;
    Border? border;

    switch (variant) {
      case SvBadgeVariant.primary:
      case SvBadgeVariant.purple:
        bg = AppColors.primary.withAlpha(25);
        fg = AppColors.primary;
        border = Border.all(color: AppColors.primary.withAlpha(60));
        break;
      case SvBadgeVariant.gold:
        bg = const Color(0xFFF59E0B).withAlpha(25);
        fg = const Color(0xFFD97706);
        border = Border.all(color: const Color(0xFFF59E0B).withAlpha(80));
        break;
      case SvBadgeVariant.success:
        bg = AppColors.successBg;
        fg = AppColors.success;
        border = Border.all(color: AppColors.success.withAlpha(60));
        break;
      case SvBadgeVariant.warning:
        bg = AppColors.warningBg;
        fg = AppColors.warning;
        border = Border.all(color: AppColors.warning.withAlpha(60));
        break;
      case SvBadgeVariant.danger:
        bg = AppColors.errorBg;
        fg = AppColors.error;
        border = Border.all(color: AppColors.error.withAlpha(60));
        break;
      case SvBadgeVariant.secondary:
        bg = isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceSecondary;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        break;
      case SvBadgeVariant.outline:
        bg = Colors.transparent;
        fg = isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary;
        border = Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        );
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 4)],
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class SvShadSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SvShadSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  const SvShadSkeleton.circular({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = 999;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppColors.darkSurfaceElevated
        : Colors.grey.shade200;
    final highlightColor = isDark
        ? AppColors.darkSurfaceTertiary
        : Colors.grey.shade50;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SvShadSearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final bool showFilterButton;

  const SvShadSearchBar({
    super.key,
    this.hintText = 'Search salons, services, or locations...',
    this.controller,
    this.onChanged,
    this.onClear,
    this.onFilterTap,
    this.showFilterButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: border),
        boxShadow: AppSpacing.softShadow(context),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller != null && controller!.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller?.clear();
                if (onClear != null) onClear!();
                if (onChanged != null) onChanged!('');
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.cancel_rounded,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ),
          if (showFilterButton && onFilterTap != null) ...[
            Container(
              height: 24,
              width: 1,
              color: border,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
