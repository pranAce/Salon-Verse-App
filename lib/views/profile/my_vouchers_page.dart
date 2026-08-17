import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonverse/controllers/loyalty_provider.dart';

class MyVouchersPage extends StatelessWidget {
  const MyVouchersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loyalty = context.watch<LoyaltyProvider>();
    final vouchers = loyalty.vouchers;

    const Color emeraldColor = Color(0xFF10B981);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Claimed Vouchers'),
      ),
      body: vouchers.isEmpty
          ? const Center(
              child: Text(
                'You have no claimed vouchers yet.\nVisit Rewards Store to claim vouchers using your credits!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: vouchers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),

              itemBuilder: (context, index) {
                final v = vouchers[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outline.withAlpha(40),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.purple.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.confirmation_number_rounded,
                          color: Colors.purple,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.reward?.title ?? 'Reward Voucher',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Claim Code: ${v.claimCode}',
                              style: const TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Valid until: ${v.validUntil.contains('T') ? v.validUntil.split('T')[0] : v.validUntil}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: emeraldColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          v.status.toUpperCase(),
                          style: const TextStyle(
                            color: emeraldColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
