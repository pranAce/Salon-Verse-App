import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/loyalty/services/loyalty_provider.dart';
import 'package:salonverse/shared/design_system/sv_feedback_states.dart';

class MyVouchersPage extends StatefulWidget {
  const MyVouchersPage({super.key});

  @override
  State<MyVouchersPage> createState() => _MyVouchersPageState();
}

class _MyVouchersPageState extends State<MyVouchersPage> {
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
    final vouchers = loyalty.vouchers;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Vouchers',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<LoyaltyProvider>().loadLoyaltyData(),
          color: AppColors.primary,
          child: vouchers.isEmpty
              ? const SVEmptyState(
                  icon: Icons.confirmation_number_outlined,
                  title: 'No Claimed Vouchers',
                  description: 'Visit the Rewards Store to redeem vouchers using your SalonVerse points.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  itemCount: vouchers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final v = vouchers[index];
                    final date = v.validUntil.contains('T') ? v.validUntil.split('T')[0] : v.validUntil;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        boxShadow: isDark ? null : AppSpacing.softShadow(context),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.confirmation_number_rounded, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.reward?.title ?? 'Reward Voucher',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Code: ${v.claimCode}',
                                      style: GoogleFonts.outfit(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(text: v.claimCode));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Voucher code "${v.claimCode}" copied!'),
                                            backgroundColor: AppColors.primary,
                                          ),
                                        );
                                      },
                                      child: const Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Valid until: $date',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SVStatusBadge(status: v.status, isCompact: true),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
