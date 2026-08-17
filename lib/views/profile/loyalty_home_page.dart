import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:salonverse/controllers/loyalty_provider.dart';
import 'package:salonverse/widgets/smart_rebook_card.dart';

class LoyaltyHomePage extends StatefulWidget {
  const LoyaltyHomePage({super.key});

  @override
  State<LoyaltyHomePage> createState() => _LoyaltyHomePageState();
}

class _LoyaltyHomePageState extends State<LoyaltyHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoyaltyProvider>().loadLoyaltyData();
    });
  }

  LinearGradient _getTierGradient(String tier) {
    switch (tier.toLowerCase()) {
      case 'luxe':
        return const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'icon':
        return const LinearGradient(
          colors: [Color(0xFF3A1C71), Color(0xFFD76D77), Color(0xFFFFAF7B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'glow':
      default:
        return const LinearGradient(
          colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getTierIcon(String tier) {
    switch (tier.toLowerCase()) {
      case 'luxe':
        return Icons.diamond_rounded;
      case 'icon':
        return Icons.workspace_premium_rounded;
      case 'glow':
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loyalty = context.watch<LoyaltyProvider>();
    final profile = loyalty.profile;
    final tierName = profile?.currentTier.toUpperCase() ?? 'GLOW';
    final credits = profile?.loyaltyCredits ?? 0;

    const Color emeraldColor = Color(0xFF10B981);
    const Color roseColor = Color(0xFFF43F5E);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SalonVerse Loyalty',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => loyalty.loadLoyaltyData(),
          ),
        ],
      ),
      body: loyalty.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => loyalty.loadLoyaltyData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Tier Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: _getTierGradient(tierName),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withAlpha(60),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getTierIcon(tierName),
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tierName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.stars_rounded,
                                color: Colors.amberAccent,
                                size: 28,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Loyalty Credits Balance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$credits Credits',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Progress Bar to Next Tier
                          if (loyalty.nextTierDetails != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress to ${loyalty.nextTierDetails!.name}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${loyalty.creditsNeededForNext} credits away',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: loyalty.progressRatio,
                                minHeight: 8,
                                backgroundColor: Colors.white.withAlpha(40),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.amberAccent,
                                ),
                              ),
                            ),
                          ] else ...[
                            const Text(
                              '👑 You have unlocked the highest ICON tier status!',
                              style: TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Action Buttons Grid
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            title: 'Rewards Store',
                            subtitle: 'Redeem Credits',
                            icon: Icons.card_giftcard_rounded,
                            color: Colors.pink,
                            onTap: () => context.push('/loyalty/rewards'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionCard(
                            title: 'My Vouchers',
                            subtitle: '${loyalty.vouchers.length} Claimed',
                            icon: Icons.confirmation_number_rounded,
                            color: Colors.purple,
                            onTap: () => context.push('/loyalty/vouchers'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionCard(
                            title: 'Refer & Earn',
                            subtitle: '+2 Credits',
                            icon: Icons.group_add_rounded,
                            color: Colors.indigo,
                            onTap: () => context.push('/profile/refer'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Smart Rebook Section
                    const SmartRebookCard(),
                    const SizedBox(height: 24),

                    // Tier Benefits Section
                    if (loyalty.currentTierDetails != null) ...[
                      Text(
                        'Your $tierName Perks',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outline.withAlpha(30),
                          ),
                        ),
                        child: Column(
                          children: loyalty.currentTierDetails!.benefits.map((b) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: emeraldColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      b,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Recent Activity Ledger Timeline
                    Text(
                      'Recent Loyalty Ledger Activity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    loyalty.activity.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.outline.withAlpha(isDark ? 20 : 40),
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.history_toggle_off_rounded,
                                  color: Colors.pink,
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No Loyalty Activity Recorded Yet',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Complete salon bookings or leave reviews to start earning Loyalty Credits!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: loyalty.activity.length > 5 ? 5 : loyalty.activity.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),

                            itemBuilder: (context, index) {
                              final txn = loyalty.activity[index];
                              final isPositive = txn.amount > 0;
                              final dateDisplay = txn.createdAt.contains('T')
                                  ? txn.createdAt.split('T')[0]
                                  : txn.createdAt;
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withAlpha(20),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: isPositive
                                          ? emeraldColor.withAlpha(30)
                                          : roseColor.withAlpha(30),
                                      child: Icon(
                                        isPositive
                                            ? Icons.add_circle_outline_rounded
                                            : Icons.remove_circle_outline_rounded,
                                        color: isPositive ? emeraldColor : roseColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            txn.description,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            dateDisplay,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      isPositive ? '+${txn.amount}' : '${txn.amount}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: isPositive ? emeraldColor : roseColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(50)),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withAlpha(30),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
