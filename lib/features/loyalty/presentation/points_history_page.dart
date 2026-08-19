import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/loyalty/services/loyalty_provider.dart';
import 'package:salonverse/features/loyalty/widgets/loyalty_tier_emblem.dart';
import 'package:salonverse/core/widgets/sv_feedback_states.dart';

class PointsHistoryPage extends StatefulWidget {
  const PointsHistoryPage({super.key});

  @override
  State<PointsHistoryPage> createState() => _PointsHistoryPageState();
}

class _PointsHistoryPageState extends State<PointsHistoryPage> {
  int _selectedFilterIndex = 0;

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

    final balance = loyalty.profile?.loyaltyCredits ?? 0;
    final lifetimeEarned = loyalty.profile?.lifetimeCreditsEarned ?? 0;
    final lifetimeRedeemed = loyalty.profile?.lifetimeCreditsRedeemed ?? 0;
    final tierKey = loyalty.profile?.currentTier ?? 'glow';

    const Color emeraldColor = Color(0xFF10B981);
    const Color roseColor = Color(0xFFEF4444);

    final filteredActivity = loyalty.activity.where((txn) {
      if (_selectedFilterIndex == 1) {
        return txn.amount > 0 && !txn.type.contains('REFERRAL');
      }
      if (_selectedFilterIndex == 2) {
        return txn.type.contains('REFERRAL') || txn.source.contains('referral');
      }
      if (_selectedFilterIndex == 3) {
        return txn.amount < 0 || txn.type.contains('REDEEMED');
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Points Ledger & History',
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CURRENT BALANCE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.lightTextTertiary,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '$balance',
                                    style: GoogleFonts.outfit(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    balance == 1 ? 'Credit' : 'Credits',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SVTierEmblem(tierKey: tierKey, size: 44),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lifetime Earned: $lifetimeEarned pts',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: emeraldColor,
                            ),
                          ),
                          Text(
                            'Redeemed: $lifetimeRedeemed pts',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceElevated
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _buildFilterTab('All', 0),
                      _buildFilterTab('Earned', 1),
                      _buildFilterTab('Referrals', 2),
                      _buildFilterTab('Redeemed', 3),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                if (loyalty.isLoading && loyalty.activity.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (filteredActivity.isEmpty)
                  const SVEmptyState(
                    icon: Icons.history_toggle_off_rounded,
                    title: 'No Transactions Found',
                    description:
                        'Your verified points ledger and earning activity will appear here.',
                  )
                else
                  ...filteredActivity.map((txn) {
                    final isPositive = txn.amount > 0;
                    final isReferral =
                        txn.type.contains('REFERRAL') ||
                        txn.source.contains('referral');
                    final dateDisplay = txn.createdAt.contains('T')
                        ? txn.createdAt.split('T')[0]
                        : txn.createdAt;

                    final IconData txnIcon;
                    final Color txnColor;

                    if (isReferral) {
                      txnIcon = Icons.group_add_rounded;
                      txnColor = const Color(0xFF6366F1);
                    } else if (isPositive) {
                      txnIcon = Icons.add_circle_outline_rounded;
                      txnColor = emeraldColor;
                    } else {
                      txnIcon = Icons.remove_circle_outline_rounded;
                      txnColor = roseColor;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.cardRadius,
                        ),
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
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: txnColor.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(txnIcon, color: txnColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  txn.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Text(
                                      dateDisplay,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: isDark
                                            ? AppColors.darkTextTertiary
                                            : AppColors.lightTextTertiary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.darkSurfaceElevated
                                            : AppColors.lightSurfaceSecondary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _formatType(txn.type),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isPositive ? '+${txn.amount}' : '${txn.amount}',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: isPositive ? emeraldColor : roseColor,
                                ),
                              ),
                              Text(
                                'pts',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.lightTextTertiary,
                                ),
                              ),
                            ],
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

  String _formatType(String type) {
    switch (type) {
      case 'LOYALTY_REFERRAL':
        return 'Referral';
      case 'LOYALTY_EARNED':
        return 'Booking';
      case 'LOYALTY_REDEEMED':
        return 'Redeemed';
      case 'LOYALTY_BONUS':
        return 'Bonus';
      case 'LOYALTY_BIRTHDAY':
        return 'Birthday';
      case 'LOYALTY_EXPIRED':
        return 'Expired';
      default:
        return type.replaceAll('LOYALTY_', '');
    }
  }

  Widget _buildFilterTab(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilterIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkSurface : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected && !isDark
                ? AppSpacing.softShadow(context)
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
