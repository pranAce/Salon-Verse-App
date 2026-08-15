import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:salonverse/controllers/booking_provider.dart';
import 'package:salonverse/controllers/settings_provider.dart';
import 'package:salonverse/theme/app_theme.dart';
import 'package:salonverse/widgets/feedback_helper.dart';

class PaymentConfirmationPage extends StatelessWidget {
  const PaymentConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookingProvider = context.watch<BookingProvider>();

    final bookings = bookingProvider.bookings;
    final lastBooking = bookings.isNotEmpty ? bookings.first : null;

    final String salonName = lastBooking?.salonName ?? "Glow Beauty Lounge";
    final String salonAddress =
        lastBooking?.salonAddress ?? "Thamel, Kathmandu";
    final String salonImageUrl =
        lastBooking?.salonImageUrl ??
        "https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=400&q=80";
    final String dateStr = lastBooking?.date ?? "Fri, Nov 14";
    final String timeStr = lastBooking?.timeSlot ?? "02:30 PM";
    final String serviceName = lastBooking?.serviceName ?? "Signature Haircut";
    final String stylistName = lastBooking?.stylistName ?? "Priya S.";
    final String bookingId = lastBooking != null
        ? (lastBooking.id.length >= 6
              ? "SV-${lastBooking.id.substring(0, 6).toUpperCase()}"
              : "SV-${lastBooking.id.toUpperCase()}")
        : "SV-284071";

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 28),

              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(50),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 52,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Booking Confirmed!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your appointment is secured.\nA confirmation has been sent to your phone.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
                  border: Border.all(
                    color: theme.colorScheme.outline.withAlpha(
                      isDark ? 30 : 60,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 0 : 5),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: salonImageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorWidget: (c, u, e) => Container(
                              color: Colors.grey,
                              width: 60,
                              height: 60,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withAlpha(
                                    15,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withAlpha(
                                      30,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "VERIFIED SALON",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                salonName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                salonAddress,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: _buildReceiptBlock(
                            context,
                            theme,
                            Icon(
                              Icons.calendar_today_rounded,
                              color: theme.colorScheme.primary,
                              size: 16,
                            ),
                            "DATE",
                            dateStr,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildReceiptBlock(
                            context,
                            theme,
                            Icon(
                              Icons.access_time_rounded,
                              color: theme.colorScheme.primary,
                              size: 16,
                            ),
                            "TIME",
                            timeStr,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildReceiptBlock(
                      context,
                      theme,
                      Icon(
                        Icons.content_cut_rounded,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      "SERVICE",
                      serviceName,
                      subtitle: "with $stylistName",
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF161514)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.tag_rounded,
                                color: theme.colorScheme.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "BOOKING ID",
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    bookingId,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: bookingId));
                              AppFeedback.success(
                                context,
                                "Booking ID copied!",
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.copy_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Copy",
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    try {
                      final title = Uri.encodeComponent(
                        "Salon Appointment: $serviceName at $salonName",
                      );
                      final details = Uri.encodeComponent(
                        "SalonVerse Booking $bookingId with stylist $stylistName. Address: $salonAddress",
                      );
                      final location = Uri.encodeComponent(salonAddress);
                      final now = DateTime.now();
                      final startFormatted =
                          "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}T100000Z";
                      final endFormatted =
                          "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}T110000Z";

                      final googleCalendarUrl = Uri.parse(
                        "https://calendar.google.com/calendar/render?action=TEMPLATE&text=$title&details=$details&location=$location&dates=$startFormatted/$endFormatted",
                      );

                      if (await canLaunchUrl(googleCalendarUrl)) {
                        await launchUrl(
                          googleCalendarUrl,
                          mode: LaunchMode.externalApplication,
                        );
                        if (context.mounted) {
                          AppFeedback.success(
                            context,
                            "Opening device calendar...",
                          );
                        }
                      } else {
                        Clipboard.setData(
                          ClipboardData(
                            text:
                                "$serviceName at $salonName on $dateStr at $timeStr. Location: $salonAddress",
                          ),
                        );
                        if (context.mounted) {
                          AppFeedback.success(
                            context,
                            "Appointment details copied to clipboard!",
                          );
                        }
                      }
                    } catch (_) {
                      Clipboard.setData(
                        ClipboardData(
                          text:
                              "$serviceName at $salonName on $dateStr at $timeStr. Location: $salonAddress",
                        ),
                      );
                      if (context.mounted) {
                        AppFeedback.success(
                          context,
                          "Appointment details copied to clipboard!",
                        );
                      }
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "Add to Calendar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    context.read<SettingsProvider>().setPage(0);
                    context.go('/home');
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_outlined, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "Back to Home",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptBlock(
    BuildContext context,
    ThemeData theme,
    Widget icon,
    String label,
    String value, {
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withAlpha(12),
          ),
          alignment: Alignment.center,
          child: icon,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
