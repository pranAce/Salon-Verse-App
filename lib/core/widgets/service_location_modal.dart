import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/salons/models/salon_model.dart';
import 'package:salonverse/features/booking/services/booking_provider.dart';
import 'package:salonverse/core/utils/currency_formatter.dart';

void showServiceLocationModal(
  BuildContext context,
  SalonModel salon,
  ServiceModel service,
) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Select Appointment Type',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${service.name} • ${CurrencyFormatter.formatNPR(service.price)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  final bk = context.read<BookingProvider>();
                  bk.startBookingFlow(salon, service);
                  bk.setHomeService(false);
                  context.push('/booking-flow');
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceElevated
                        : AppColors.lightSurfaceSecondary,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'In-Salon Appointment',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'Visit ${salon.name} venue',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.lightTextTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ],
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  final bk = context.read<BookingProvider>();
                  bk.startBookingFlow(salon, service);
                  bk.setHomeService(true);
                  context.push('/booking-flow');
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceElevated
                        : AppColors.lightSurfaceSecondary,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.home_repair_service_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Home Service Delivery',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'Verified stylist comes to your location',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.lightTextTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
