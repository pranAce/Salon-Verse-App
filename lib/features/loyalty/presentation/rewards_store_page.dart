import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/loyalty/services/loyalty_provider.dart';
import 'package:salonverse/features/loyalty/models/loyalty_model.dart';
import 'package:salonverse/shared/design_system/sv_button.dart';
import 'package:salonverse/shared/design_system/sv_feedback_states.dart';

class RewardsStorePage extends StatefulWidget {
  const RewardsStorePage({super.key});

  @override
  State<RewardsStorePage> createState() => _RewardsStorePageState();
}

class _RewardsStorePageState extends State<RewardsStorePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoyaltyProvider>().loadLoyaltyData();
    });
  }

  void _showRedeemConfirmation(
    BuildContext context,
    LoyaltyRewardModel reward,
    int userCredits,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.sheetRadius)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Redeem Reward',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Unlock "${reward.title}" with your points.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceSecondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildRow('Points Required', '${reward.creditsRequired} pts', isDark),
                    const SizedBox(height: 8),
                    _buildRow('Your Balance', '$userCredits pts', isDark),
                    const Divider(height: 20),
                    _buildRow(
                      'Remaining Balance',
                      '${userCredits - reward.creditsRequired} pts',
                      isDark,
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: SVButton(
                      text: 'Cancel',
                      variant: SVButtonVariant.outline,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SVButton(
                      text: 'Confirm Redeem',
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final loyalty = context.read<LoyaltyProvider>();
                        final success = await loyalty.claimReward(reward.id);
                        if (context.mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reward claimed! Voucher added to My Vouchers.'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(loyalty.error ?? 'Redemption failed.'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value, bool isDark, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: isBold
              ? GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary)
              : GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loyalty = context.watch<LoyaltyProvider>();
    final rewards = loyalty.rewards;
    final userCredits = loyalty.profile?.loyaltyCredits ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rewards Store',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<LoyaltyProvider>().loadLoyaltyData(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    boxShadow: isDark ? null : AppSpacing.softShadow(context),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Current Balance',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      Text(
                        '$userCredits pts',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (rewards.isEmpty)
                  const SVEmptyState(
                    icon: Icons.card_giftcard_rounded,
                    title: 'No Rewards Available',
                    description: 'Rewards are currently being refreshed. Check back soon!',
                  )
                else
                  ...rewards.map((r) {
                    final canAfford = userCredits >= r.creditsRequired;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        boxShadow: isDark ? null : AppSpacing.softShadow(context),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.card_giftcard_rounded, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${r.creditsRequired} points needed',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: canAfford
                                        ? AppColors.primary
                                        : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SVButton(
                            text: canAfford ? 'Redeem' : 'Need Pts',
                            size: SVButtonSize.sm,
                            variant: canAfford ? SVButtonVariant.primary : SVButtonVariant.outline,
                            onPressed: canAfford
                                ? () => _showRedeemConfirmation(context, r, userCredits)
                                : null,
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
