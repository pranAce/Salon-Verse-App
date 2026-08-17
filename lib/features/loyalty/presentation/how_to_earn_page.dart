import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonverse/features/loyalty/services/loyalty_provider.dart';

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
        title: const Text(
          'How to Earn Points',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<LoyaltyProvider>().loadLoyaltyData(),
          ),
        ],
      ),
      body: loyalty.isLoading && loyalty.rules.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : loyalty.rules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars_rounded, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        'No earning rules available right now.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<LoyaltyProvider>().loadLoyaltyData(),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => context.read<LoyaltyProvider>().loadLoyaltyData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Answer one simple question: how to get more rewards! Complete any of the actions below to automatically receive points.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Column(
                          children: [
                            for (final rule in loyalty.rules) ...[
                              Builder(
                                builder: (context) {
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
                                  } else if (rule.ruleKey.contains('RETENTION')) {
                                    iconData = Icons.card_membership_rounded;
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: theme.colorScheme.outline.withAlpha(isDark ? 20 : 40),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEC4899).withAlpha(15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(iconData, color: const Color(0xFFEC4899), size: 20),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                rule.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                rule.description,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: emeraldColor.withAlpha(20),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '+${rule.creditsToAward} ${rule.creditsToAward == 1 ? "pt" : "pts"}',
                                            style: const TextStyle(
                                              color: emeraldColor,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12,
                                            ),
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
