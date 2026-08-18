import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/shared/design_system/sv_button.dart';

/// Modern Universal Status Badge
class SVStatusBadge extends StatelessWidget {
  final String status;
  final bool isCompact;

  const SVStatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cleanStatus = status.trim().toLowerCase();
    Color bg;
    Color textColor;
    IconData icon;
    String label;

    switch (cleanStatus) {
      case 'confirmed':
        bg = const Color(0xFF10B981).withAlpha(20);
        textColor = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
        label = 'Confirmed';
        break;
      case 'in_queue':
      case 'in queue':
        bg = const Color(0xFFF59E0B).withAlpha(20);
        textColor = const Color(0xFFF59E0B);
        icon = Icons.hourglass_top_rounded;
        label = 'In Queue';
        break;
      case 'serving':
      case 'in progress':
      case 'in_progress':
        bg = AppColors.primary.withAlpha(20);
        textColor = AppColors.primary;
        icon = Icons.auto_awesome_rounded;
        label = 'Serving';
        break;
      case 'completed':
        bg = const Color(0xFF059669).withAlpha(20);
        textColor = const Color(0xFF059669);
        icon = Icons.task_alt_rounded;
        label = 'Completed';
        break;
      case 'cancelled':
      case 'canceled':
        bg = const Color(0xFFEF4444).withAlpha(20);
        textColor = const Color(0xFFEF4444);
        icon = Icons.cancel_rounded;
        label = 'Cancelled';
        break;
      case 'pending':
        bg = const Color(0xFF3B82F6).withAlpha(20);
        textColor = const Color(0xFF3B82F6);
        icon = Icons.schedule_rounded;
        label = 'Pending';
        break;
      default:
        bg = Colors.grey.withAlpha(25);
        textColor = Colors.grey;
        icon = Icons.info_outline_rounded;
        label = status.isNotEmpty ? '${status[0].toUpperCase()}${status.substring(1)}' : 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: textColor.withAlpha(50), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 11 : 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Polished Empty State with clear explanations and CTA
class SVEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;

  const SVEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.iconSize = 56,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize * 1.5,
              height: iconSize * 1.5,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.primaryTint,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.primary.withAlpha(40),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: iconSize * 0.9,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.35,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              SVButton(
                text: actionLabel!,
                onPressed: onAction,
                variant: SVButtonVariant.secondary,
                size: SVButtonSize.sm,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Polished Error State with friendly guidance & retry
class SVErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const SVErrorState({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: isDark ? null : AppSpacing.softShadow(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.cloud_off_rounded,
                    color: AppColors.error,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 18),
                SVButton(
                  text: retryLabel,
                  onPressed: onRetry,
                  variant: SVButtonVariant.secondary,
                  size: SVButtonSize.sm,
                  icon: Icons.refresh_rounded,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer Skeleton Loaders
class SVSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final ShapeBorder? shape;

  const SVSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
    this.shape,
  });

  const SVSkeleton.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = 999,
        shape = const CircleBorder();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF221F1C) : const Color(0xFFF5E6EC);
    final highlightColor = isDark ? const Color(0xFF332F2A) : const Color(0xFFFFF0F5);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: shape != null
            ? ShapeDecoration(shape: shape!, color: baseColor)
            : BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
      ),
    );
  }

  static Widget salonCardSkeleton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(30),
        ),
      ),
      child: Row(
        children: [
          const SVSkeleton(width: 90, height: 90, borderRadius: 16),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SVSkeleton(width: 160, height: 16, borderRadius: 6),
                SizedBox(height: 8),
                SVSkeleton(width: 120, height: 12, borderRadius: 4),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SVSkeleton(width: 60, height: 14, borderRadius: 4),
                    SVSkeleton(width: 70, height: 14, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
