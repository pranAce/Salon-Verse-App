import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/booking/models/booking_model.dart';
import 'package:salonverse/core/utils/currency_formatter.dart';
import 'package:salonverse/core/utils/receipt_pdf_helper.dart';
import 'package:salonverse/core/widgets/sv_button.dart';
import 'package:salonverse/core/widgets/sv_feedback_states.dart';

class PaymentConfirmationPage extends StatelessWidget {
  const PaymentConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final booking = extra?['booking'] as BookingModel?;

    if (booking == null || booking.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Status')),
        body: SVEmptyState(
          icon: Icons.search_off_rounded,
          title: 'Booking Info Unavailable',
          description:
              'We could not locate confirmation details. Please check your booking history.',
          actionLabel: 'Go to My Appointments',
          onAction: () => context.go('/bookings'),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'Booking Confirmed!',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your appointment is scheduled with the salon.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),

              Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceElevated
                            : AppColors.lightSurfaceSecondary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppSpacing.cardRadius),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'APPOINTMENT TICKET',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.6,
                            ),
                          ),
                          Text(
                            'ID: #${booking.id.length > 8 ? booking.id.substring(0, 8).toUpperCase() : booking.id.toUpperCase()}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary,
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
                          Text(
                            booking.salonName,
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            booking.serviceName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Divider(),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: _buildMetaColumn(
                                  'DATE',
                                  booking.date,
                                  isDark,
                                ),
                              ),
                              Expanded(
                                child: _buildMetaColumn(
                                  'TIME',
                                  booking.timeSlot,
                                  isDark,
                                ),
                              ),
                              Expanded(
                                child: _buildMetaColumn(
                                  'STATUS',
                                  booking.status.toUpperCase(),
                                  isDark,
                                  isHighlight: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 14),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Paid / Due',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.formatNPR(
                                  booking.servicePrice,
                                ),
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SVButton(
                text: 'Download Invoice / Receipt',
                variant: SVButtonVariant.secondary,
                isFullWidth: true,
                icon: Icons.receipt_long_rounded,
                onPressed: () async {
                  await ReceiptPdfHelper.generateAndDownloadReceipt(
                    context: context,
                    booking: booking,
                  );
                },
              ),
              const SizedBox(height: 10),
              SVButton(
                text: 'View My Appointments',
                isFullWidth: true,
                onPressed: () => context.go('/bookings'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(
                  'Back to Discovery',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaColumn(
    String label,
    String value,
    bool isDark, {
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isHighlight
                ? AppColors.primary
                : (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }
}
