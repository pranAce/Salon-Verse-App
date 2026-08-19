import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/loyalty/services/loyalty_provider.dart';
import 'package:salonverse/features/loyalty/models/loyalty_model.dart';
import 'package:salonverse/features/auth/services/auth_provider.dart';
import 'package:salonverse/features/loyalty/widgets/loyalty_tier_emblem.dart';

class LoyaltyHomePage extends StatefulWidget {
  const LoyaltyHomePage({super.key});

  @override
  State<LoyaltyHomePage> createState() => _LoyaltyHomePageState();
}

class _LoyaltyHomePageState extends State<LoyaltyHomePage> {
  int _selectedTierTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loyalty = context.read<LoyaltyProvider>();
      loyalty.loadLoyaltyData().then((_) {
        if (mounted && loyalty.profile != null) {
          final tKey = loyalty.profile!.currentTier.toLowerCase();
          if (tKey.contains('icon')) {
            setState(() => _selectedTierTab = 2);
          } else if (tKey.contains('luxe')) {
            setState(() => _selectedTierTab = 1);
          } else {
            setState(() => _selectedTierTab = 0);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loyalty = context.watch<LoyaltyProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final profile = loyalty.profile;
    final tierKey = profile?.currentTier ?? 'glow';
    final tierName = (loyalty.currentTierDetails?.name ?? tierKey)
        .toUpperCase();
    final points = profile?.loyaltyCredits ?? 0;
    final nextTierName = loyalty.nextTierDetails?.name.toUpperCase();
    final progress = loyalty.progressRatio.clamp(0.0, 1.0);
    final pointsNeeded = loyalty.creditsNeededForNext;

    final Color tierPrimary;
    final Color tierSecondary;
    final Color tierAccent;
    final List<Color> cardBgGradient;

    if (tierKey == 'icon') {
      tierPrimary = const Color(0xFFF59E0B);
      tierSecondary = const Color(0xFFD97706);
      tierAccent = const Color(0xFFFDE68A);
      cardBgGradient = const [
        Color(0xFF261904),
        Color(0xFF191002),
        Color(0xFF0D0801),
      ];
    } else if (tierKey == 'luxe') {
      tierPrimary = const Color(0xFF8B5CF6);
      tierSecondary = const Color(0xFF6D28D9);
      tierAccent = const Color(0xFFDDD6FE);
      cardBgGradient = const [
        Color(0xFF1E1033),
        Color(0xFF140A24),
        Color(0xFF0A0512),
      ];
    } else {
      tierPrimary = const Color(0xFFE11D48);
      tierSecondary = const Color(0xFF9F1239);
      tierAccent = const Color(0xFFFFE4E6);
      cardBgGradient = const [
        Color(0xFF2E0914),
        Color(0xFF1F050D),
        Color(0xFF100207),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Loyalty & VIP Club',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Points Ledger',
            icon: const Icon(Icons.receipt_long_rounded),
            onPressed: () => context.push('/loyalty/history'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: loyalty.isLoading && !loyalty.hasLoadedData
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : RefreshIndicator(
                onRefresh: () => loyalty.loadLoyaltyData(),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLuxuryVIPCard(
                        tierKey: tierKey,
                        tierName: tierName,
                        points: points,
                        userName: user?.name ?? 'Valued Member',
                        userId: user?.id ?? 'SV8921',
                        nextTierName: nextTierName,
                        pointsNeeded: pointsNeeded,
                        progress: progress,
                        tierPrimary: tierPrimary,
                        tierSecondary: tierSecondary,
                        tierAccent: tierAccent,
                        cardBgGradient: cardBgGradient,
                        multiplier:
                            loyalty.currentTierDetails?.earningMultiplier ??
                            1.0,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 22),

                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.storefront_rounded,
                              title: 'Rewards Store',
                              subtitle: '${loyalty.rewards.length} Vouchers',
                              accent: AppColors.primary,
                              onTap: () => context.push('/loyalty/rewards'),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.confirmation_number_rounded,
                              title: 'My Vouchers',
                              subtitle: '${loyalty.vouchers.length} Claimed',
                              accent: const Color(0xFF8B5CF6),
                              onTap: () => context.push('/loyalty/vouchers'),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.group_add_rounded,
                              title: 'Refer & Earn',
                              subtitle: '100 pts / Friend',
                              accent: const Color(0xFF10B981),
                              onTap: () => context.push('/profile/refer'),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.history_rounded,
                              title: 'Points Ledger',
                              subtitle: 'Statements',
                              accent: const Color(0xFFF59E0B),
                              onTap: () => context.push('/loyalty/history'),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      if (loyalty.rewards.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Featured Rewards',
                              style: GoogleFonts.outfit(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/loyalty/rewards'),
                              child: Text(
                                'View All →',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 142,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: loyalty.rewards.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final r = loyalty.rewards[index];
                              final canAfford = points >= r.creditsRequired;

                              return Container(
                                width: 220,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurface
                                      : Colors.white,
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryTint,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.card_giftcard_rounded,
                                            size: 18,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            r.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: isDark
                                                  ? AppColors.darkTextPrimary
                                                  : AppColors.lightTextPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      r.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: isDark
                                            ? AppColors.darkTextTertiary
                                            : AppColors.lightTextTertiary,
                                        height: 1.2,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${r.creditsRequired} pts',
                                          style: GoogleFonts.outfit(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: canAfford
                                                ? AppColors.primary
                                                : Colors.grey,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              context.push('/loyalty/rewards'),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: canAfford
                                                  ? AppColors.primary
                                                  : (isDark
                                                        ? AppColors
                                                              .darkSurfaceElevated
                                                        : Colors.grey.shade200),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Claim',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: canAfford
                                                        ? Colors.white
                                                        : Colors.grey,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      Text(
                        'Membership Tiers & VIP Perks',
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unlock higher earning multipliers, birthday gifts, and exclusive VIP access.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceElevated
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildTierTab('GLOW', 0, AppColors.primary, isDark),
                            _buildTierTab(
                              'LUXE',
                              1,
                              const Color(0xFF8B5CF6),
                              isDark,
                            ),
                            _buildTierTab(
                              'ICON',
                              2,
                              const Color(0xFFF59E0B),
                              isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (loyalty.allTiers.isNotEmpty)
                        _buildActiveTierInspectionCard(
                          loyalty.allTiers[_selectedTierTab.clamp(
                            0,
                            loyalty.allTiers.length - 1,
                          )],
                          tierKey,
                          isDark,
                        ),
                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'How to Earn Points',
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/loyalty/earn'),
                            child: Text(
                              'All Rules →',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(16),
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
                        child: Column(
                          children: loyalty.rules.map((r) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withAlpha(20),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: Color(0xFF10B981),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.name,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.lightTextPrimary,
                                          ),
                                        ),
                                        Text(
                                          r.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: isDark
                                                ? AppColors.darkTextTertiary
                                                : AppColors.lightTextTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withAlpha(25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '+${r.creditsToAward} pts',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLuxuryVIPCard({
    required String tierKey,
    required String tierName,
    required int points,
    required String userName,
    required String userId,
    required String? nextTierName,
    required int pointsNeeded,
    required double progress,
    required Color tierPrimary,
    required Color tierSecondary,
    required Color tierAccent,
    required List<Color> cardBgGradient,
    required double multiplier,
    required bool isDark,
  }) {
    final shortId = userId.length > 6
        ? userId.substring(userId.length - 6).toUpperCase()
        : userId.toUpperCase();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cardBgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tierPrimary.withAlpha(90), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: tierPrimary.withAlpha(isDark ? 35 : 22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black45,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [tierPrimary.withAlpha(30), Colors.transparent],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SVTierEmblem(
                          tierKey: tierKey,
                          size: 40,
                          isGlowEnabled: true,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SALONVERSE VIP',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white60,
                                letterSpacing: 1.4,
                              ),
                            ),
                            Text(
                              '$tierName PASS',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: tierAccent,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (multiplier > 1.0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              tierPrimary.withAlpha(50),
                              tierSecondary.withAlpha(30),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: tierPrimary.withAlpha(90)),
                        ),
                        child: Text(
                          '${multiplier}x Points Rate',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: tierAccent,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AUTHORITATIVE BALANCE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white54,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$points',
                              style: GoogleFonts.outfit(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Points',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: tierPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          userName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '#VIP-$shortId',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white54,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(18)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            nextTierName != null && pointsNeeded > 0
                                ? '$pointsNeeded more points to unlock $nextTierName'
                                : 'Highest VIP Level Achieved ($tierName)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            nextTierName != null
                                ? '${(progress * 100).toInt()}%'
                                : 'MAX',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: tierAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: nextTierName != null ? progress : 1.0,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            tierPrimary,
                          ),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierTab(String label, int index, Color color, bool isDark) {
    final isSelected = _selectedTierTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTierTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkSurface : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected && !isDark
                ? AppSpacing.softShadow(context)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? color
                      : (isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTierInspectionCard(
    LoyaltyTierModel tier,
    String currentTierKey,
    bool isDark,
  ) {
    final isCurrent =
        tier.tierKey.toLowerCase() == currentTierKey.toLowerCase();
    final level = SVTierLevel.fromString(tier.tierKey);

    final Color tierAccent;
    if (level == SVTierLevel.icon) {
      tierAccent = const Color(0xFFF59E0B);
    } else if (level == SVTierLevel.luxe) {
      tierAccent = const Color(0xFF8B5CF6);
    } else {
      tierAccent = AppColors.primary;
    }

    final pointsRange = tier.maxCredits != null
        ? '${tier.minCredits} – ${tier.maxCredits} Points'
        : '${tier.minCredits}+ Points';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: isCurrent
              ? tierAccent
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isCurrent ? 1.8 : 1.0,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: tierAccent.withAlpha(isDark ? 30 : 18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : (isDark ? null : AppSpacing.softShadow(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tierAccent.withAlpha(isDark ? 24 : 14),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.cardRadius),
              ),
            ),
            child: Row(
              children: [
                SVTierEmblem(tierKey: tier.tierKey, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tier.name.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: tierAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'YOUR TIER',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        pointsRange,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: tierAccent,
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
                    color: tierAccent.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${tier.earningMultiplier}x Points Rate',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: tierAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStatPill(
                      'Birthday Reward',
                      'Rs. ${tier.birthdayRewardValue}',
                      isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildStatPill(
                      'Referral Bonus',
                      '${tier.referralBonusCredits} pts',
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  'Exclusive Tier Benefits',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ...tier.benefits.map((benefit) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: tierAccent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            benefit,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              height: 1.3,
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
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceElevated
              : AppColors.lightSurfaceSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: isDark ? null : AppSpacing.softShadow(context),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 11,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
