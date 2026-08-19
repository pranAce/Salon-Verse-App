import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/loyalty/services/loyalty_provider.dart';
import 'package:salonverse/core/widgets/feedback_helper.dart';
import 'package:salonverse/core/widgets/sv_button.dart';
import 'package:salonverse/core/widgets/sv_selection_widgets.dart';

class ReferPage extends StatefulWidget {
  const ReferPage({super.key});

  @override
  State<ReferPage> createState() => _ReferPageState();
}

class _ReferPageState extends State<ReferPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoyaltyProvider>().loadLoyaltyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loyalty = context.watch<LoyaltyProvider>();
    final referralCode = loyalty.referralCode.isNotEmpty
        ? loyalty.referralCode
        : (loyalty.profile?.referralCode ?? '');

    final referralRule = loyalty.rules
        .where((r) => r.ruleKey == 'REFERRAL_QUALIFIED')
        .firstOrNull;
    final bonusCredits =
        (loyalty.currentTierDetails != null &&
            loyalty.currentTierDetails!.referralBonusCredits > 0)
        ? loyalty.currentTierDetails!.referralBonusCredits
        : (referralRule?.creditsToAward ?? 0);

    const Color emeraldColor = Color(0xFF10B981);

    final totalReferralCreditsEarned = loyalty.activity
        .where(
          (t) => t.type.contains('REFERRAL') || t.source.contains('referral'),
        )
        .fold<int>(0, (sum, t) => sum + (t.amount > 0 ? t.amount : 0));

    final displayEarned = totalReferralCreditsEarned > 0
        ? totalReferralCreditsEarned
        : (loyalty.completedReferrals * (bonusCredits > 0 ? bonusCredits : 1));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Refer & Earn',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  shape: BoxShape.circle,
                  boxShadow: AppSpacing.glowShadow(
                    AppColors.primary,
                    opacity: 0.35,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.card_giftcard_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                bonusCredits > 0
                    ? 'Earn $bonusCredits Points Per Referral!'
                    : 'Earn Points With Every Referral!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Share your code with friends. When they register using your code and complete their first salon appointment, you earn authoritative loyalty points!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                  boxShadow: isDark ? null : AppSpacing.softShadow(context),
                ),
                child: Column(
                  children: [
                    Text(
                      'YOUR EXCLUSIVE REFERRAL CODE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceElevated
                            : AppColors.lightSurfaceSecondary,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(50),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            referralCode,
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          SVButton(
                            text: 'Copy',
                            size: SVButtonSize.sm,
                            icon: Icons.copy_rounded,
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: referralCode),
                              );
                              AppFeedback.success(
                                context,
                                'Referral code "$referralCode" copied to clipboard!',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Successful Referrals',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${loyalty.completedReferrals}',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: emeraldColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 28,
                      width: 1,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    Column(
                      children: [
                        Text(
                          'Points Earned',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$displayEarned',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: SVSectionHeader(title: 'How It Works'),
              ),
              const SizedBox(height: 8),
              _buildStepItem(
                '1',
                'Share code',
                'Share your referral code with friends & family.',
                isDark,
              ),
              _buildStepItem(
                '2',
                'Friend registers with code',
                'New friends enter your referral code when creating their account.',
                isDark,
              ),
              _buildStepItem(
                '3',
                'Earn loyalty points',
                'You receive authoritative loyalty points when they complete their first booking!',
                isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(String num, String title, String desc, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: AppColors.primaryTint,
            child: Text(
              num,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
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
