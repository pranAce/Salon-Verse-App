import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:salonverse/models/salon_model.dart';
import 'package:salonverse/controllers/booking_provider.dart';
import 'package:salonverse/theme/app_theme.dart';
import 'package:salonverse/widgets/feedback_helper.dart';
import 'package:salonverse/views/salon/booking_widgets/booking_payment_modals.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (selectedService == null) {
      return const SizedBox.shrink();
    }

    final isStep1 = currentStep == 0;
    final stylistName = selectedStylist?.name.split(' ')[0] ?? 'Assigned Staff';
    final double finalPrice = (selectedService!.price - provider.discountAmount)
        .clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161514) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 0 : 8),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E1C1B) : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isStep1 ? selectedService!.name : "Total Amount",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isStep1 ? FontWeight.bold : FontWeight.w600,
                    fontSize: isStep1 ? 14 : 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    if (provider.discountAmount > 0) ...[
                      Text(
                        "Rs. ${selectedService!.price.round()} ",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    Text(
                      "Rs. ${finalPrice.round()}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFEC4899),
                      ),
                    ),
                    if (isStep1) ...[
                      Text(
                        "• $stylistName",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(140, 48),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: const Color(0xFFEC4899),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: provider.isLoading
                ? null
                : () async {
                    if (isStep1) {
                      onContinueToStep2();
                    } else {
                      if (provider.selectedTime == null) {
                        AppFeedback.warning(
                          context,
                          "Please pick an appointment time slot.",
                        );
                        return;
                      }

                      final router = GoRouter.of(context);

                      Future<void> executeBooking(String txnId) async {
                        final successBooking = await provider.confirmBooking();
                        if (!context.mounted) return;
                        if (successBooking != null) {
                          if (txnId.isNotEmpty) {
                            await provider.recordPayment(
                              successBooking.id,
                              provider.paymentMethod,
                              finalPrice,
                              txnId,
                            );
                          }
                          router.replace('/payment-confirmation');
                        } else {
                          AppFeedback.error(
                            context,
                            provider.error ?? "Failed to book slot.",
                          );
                        }
                      }

                      if (provider.paymentMethod == 'eSewa') {
                        final txnId =
                            "ESEWA-TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
                        BookingPaymentModals.showEsewaPaymentModal(
                          context,
                          provider,
                          finalPrice,
                          () {
                            executeBooking(txnId);
                          },
                        );
                      } else if (provider.paymentMethod == 'Khalti') {
                        final txnId =
                            "KHALTI-TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
                        BookingPaymentModals.showKhaltiPaymentModal(
                          context,
                          provider,
                          finalPrice,
                          () {
                            executeBooking(txnId);
                          },
                        );
                      } else {
                        executeBooking('');
                      }
                    }
                  },
            child: provider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isStep1 ? "Continue" : "Confirm & Pay",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
