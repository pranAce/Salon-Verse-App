import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/loyalty/services/loyalty_provider.dart';
import 'package:salonverse/core/widgets/sv_feedback_states.dart';

class HowToEarnPage extends StatefulWidget {
  const HowToEarnPage({super.key});

  @override
  State<HowToEarnPage> createState() => _HowToEarnPageState();
}

class _HowToEarnPageState extends State<HowToEarnPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loyalty = context.read<LoyaltyProvider>();
      if (!loyalty.hasLoadedData && !loyalty.isLoading) {
        loyalty.loadLoyaltyData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loyalty = context.watch<LoyaltyProvider>();
    const Color emeraldColor = Color(0xFF10B981);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'How to Earn Points',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: loyalty.isLoading && loyalty.rules.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    context.read<LoyaltyProvider>().loadLoyaltyData(),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Earn SalonVerse points with every booking and activity. Points can be redeemed for exclusive discounts and free vouchers.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (loyalty.rules.isEmpty)
                        const SVEmptyState(
                          icon: Icons.stars_rounded,
                          title: 'No Earning Rules Found',
                          description: 'Earning rules are being updated.',
                        )
                      else
                        ...loyalty.rules.map((rule) {
                          IconData iconData = Icons.stars_rounded;
                          if (rule.ruleKey.contains('BOOKING')) {
                            iconData = Icons.content_cut_rounded;
                          } else if (rule.ruleKey.contains('SALON')) {
                            iconData = Icons.storefront_rounded;
                          } else if (rule.ruleKey.contains('SERVICE')) {
                            iconData = Icons.auto_awesome_rounded;
                          } else if (rule.ruleKey.contains('REVIEW')) {
                            iconData = Icons.star_rate_rounded;
                          } else if (rule.ruleKey.contains('REFERRAL')) {
                            iconData = Icons.group_add_rounded;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                              boxShadow: isDark
                                  ? null
                                  : AppSpacing.softShadow(context),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTint,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    iconData,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rule.name,
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        rule.description,
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: emeraldColor.withAlpha(20),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '+${rule.creditsToAward} pts',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: emeraldColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
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
