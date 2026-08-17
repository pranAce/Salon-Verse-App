import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonverse/controllers/loyalty_provider.dart';
import 'package:salonverse/widgets/feedback_helper.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loyalty = context.watch<LoyaltyProvider>();
    final rewards = loyalty.rewards;
    final userCredits = loyalty.profile?.loyaltyCredits ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards Catalog & Vouchers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<LoyaltyProvider>().loadLoyaltyData(),
          ),
        ],
      ),
      body: loyalty.isLoading
          ? const Center(child: CircularProgressIndicator())
          : rewards.isEmpty
              ? const Center(
                  child: Text('No rewards currently available for your tier.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: rewards.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),

                  itemBuilder: (context, index) {
                    final r = rewards[index];
                    final canAfford = userCredits >= r.creditsRequired;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: canAfford
                              ? Colors.pink.withAlpha(80)
                              : theme.colorScheme.outline.withAlpha(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
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
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.pink.withAlpha(20),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${r.creditsRequired} CREDITS',
                                  style: const TextStyle(
                                    color: Colors.pink,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Text(
                                r.requiredTier.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            r.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r.description,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rs. ${r.discountValue.toInt()} OFF',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: canAfford
                                    ? () async {
                                        final success = await loyalty.claimReward(r.id);
                                        if (context.mounted) {
                                          if (success) {
                                            AppFeedback.success(
                                              context,
                                              'Voucher claimed successfully! Check My Vouchers.',
                                            );
                                          } else {
                                            AppFeedback.error(
                                              context,
                                              loyalty.error ?? 'Claim failed.',
                                            );
                                          }
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                  foregroundColor: Colors.white,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(canAfford ? 'Claim Reward' : 'Need More Credits'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
