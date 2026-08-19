import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/salons/models/salon_model.dart';
import 'package:salonverse/features/booking/services/booking_provider.dart';
import 'package:salonverse/core/utils/currency_formatter.dart';
import 'package:salonverse/shared/design_system/sv_button.dart';

class BookingBottomBar extends StatelessWidget {
  final int currentStep;
  final ServiceModel? selectedService;
  final StylistModel? selectedStylist;
  final BookingProvider provider;
  final VoidCallback onContinueToStep2;

  const BookingBottomBar({
    super.key,
    required this.currentStep,
    required this.selectedService,
    required this.selectedStylist,
    required this.provider,
    required this.onContinueToStep2,
  });

  Future<void> _handleConfirmBooking(BuildContext context) async {
    if (provider.selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an available time slot.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final booking = await provider.confirmBooking();
    if (context.mounted) {
      if (booking != null) {
        context.pushReplacement('/payment-confirmation', extra: {'booking': booking});
      } else if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final servicePrice = selectedService?.price ?? 0.0;
    final discount = provider.discountAmount;
    final finalPrice = servicePrice - discount > 0 ? servicePrice - discount : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL AMOUNT',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.formatNPR(finalPrice),
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SVButton(
              text: 'Confirm Booking',
              isLoading: provider.isLoading,
              onPressed: () => _handleConfirmBooking(context),
              icon: Icons.check_circle_rounded,
              size: SVButtonSize.md,
            ),
          ],
        ),
      ),
    );
  }
}
