import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/loyalty/services/loyalty_provider.dart';
import 'package:salonverse/features/loyalty/widgets/loyalty_tier_emblem.dart';

enum LoyaltyBannerVariant { compact, full }

class LoyaltyMembershipBanner extends StatelessWidget {
  final LoyaltyBannerVariant variant;
  final VoidCallback? onTap;

  const LoyaltyMembershipBanner({
    super.key,
    this.variant = LoyaltyBannerVariant.compact,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loyalty = context.watch<LoyaltyProvider>();

    if (loyalty.isLoading && !loyalty.hasLoadedData) {
      return _buildSkeleton(isDark);
    }

    final tierKey = loyalty.profile?.currentTier ?? 'glow';
    final tierName = (loyalty.currentTierDetails?.name ?? tierKey)
        .toUpperCase();
    final points = loyalty.profile?.loyaltyCredits ?? 0;

    final Color tierColor;
    if (tierKey == 'icon') {
      tierColor = const Color(0xFFF59E0B);
    } else if (tierKey == 'luxe') {
      tierColor = const Color(0xFF8B5CF6);
    } else {
      tierColor = const Color(0xFFE11D48);
    }

    return GestureDetector(
      onTap: onTap ?? () => context.push('/loyalty'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: isDark ? tierColor.withAlpha(50) : tierColor.withAlpha(35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: tierColor.withAlpha(isDark ? 20 : 12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            SVTierEmblem(
              tierKey: tierKey,
              size: variant == LoyaltyBannerVariant.compact ? 42 : 48,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: tierColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$tierName MEMBER',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: tierColor,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      if (loyalty.currentTierDetails != null &&
                          loyalty.currentTierDetails!.earningMultiplier >
                              1.0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${loyalty.currentTierDetails!.earningMultiplier}x Points',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$points',
                        style: GoogleFonts.outfit(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        points == 1 ? 'Credit' : 'Credits',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Perks',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: tierColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: tierColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(bool isDark) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceElevated
                  : AppColors.lightSurfaceSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceElevated
                        : AppColors.lightSurfaceSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 110,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceElevated
                        : AppColors.lightSurfaceSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
