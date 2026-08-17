import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonverse/features/loyalty/services/loyalty_provider.dart';
import 'package:salonverse/features/loyalty/models/loyalty_model.dart';
import 'package:salonverse/core/widgets/feedback_helper.dart';

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
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Redeem Reward?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You are about to redeem ${reward.title}.',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141414) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Points Required', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text('${reward.creditsRequired} points', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Your Balance', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text('$userCredits points', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Balance After', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(
                          '${userCredits - reward.creditsRequired} points',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFEC4899),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC4899),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final loyalty = context.read<LoyaltyProvider>();
                        final success = await loyalty.claimReward(reward.id);
                        if (context.mounted) {
                          if (success) {
                            AppFeedback.success(
                              context,
                              'Reward claimed! Check My Vouchers.',
                            );
                          } else {
                            AppFeedback.error(
                              context,
                              loyalty.error ?? 'Redemption failed.',
                            );
                          }
                        }
                      },
                      child: const Text('Redeem', style: TextStyle(fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loyalty = context.watch<LoyaltyProvider>();
    final rewards = loyalty.rewards;
    final userCredits = loyalty.profile?.loyaltyCredits ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<LoyaltyProvider>().loadLoyaltyData(),
          ),
        ],
      ),
      body: loyalty.isLoading && rewards.isEmpty && !loyalty.hasLoadedData
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<LoyaltyProvider>().loadLoyaltyData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Use your points to unlock rewards.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Balance header card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 20 : 40)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your balance:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Text(
                          '$userCredits points',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFEC4899),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Rewards List
                  rewards.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          child: const Column(
                            children: [
                              Icon(Icons.card_giftcard_rounded, size: 40, color: Colors.grey),
                              SizedBox(height: 12),
                              Text(
                                'No rewards available yet.',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Keep earning points and check back soon.',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            for (final r in rewards) ...[
                              Builder(
                                builder: (context) {
                                  final canAfford = userCredits >= r.creditsRequired;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: theme.colorScheme.outline.withAlpha(isDark ? 20 : 40),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                r.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${r.creditsRequired} points',
                                                style: const TextStyle(
                                                  color: Color(0xFFEC4899),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              if (!canAfford) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${r.creditsRequired} required · $userCredits available',
                                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: canAfford ? const Color(0xFFEC4899) : Colors.grey.shade400,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          ),
                                          onPressed: canAfford ? () => _showRedeemConfirmation(context, r, userCredits) : null,
                                          child: Text(
                                            canAfford ? 'Redeem' : 'Not enough points',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                ],
              ),
            ),
          ),
    );
  }
}
