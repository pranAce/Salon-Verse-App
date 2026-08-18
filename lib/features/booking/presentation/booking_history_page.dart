import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/booking/services/booking_provider.dart';
import 'package:salonverse/features/booking/models/booking_model.dart';
import 'package:salonverse/core/utils/receipt_pdf_helper.dart';
import 'package:salonverse/core/utils/currency_formatter.dart';
import 'package:salonverse/shared/design_system/sv_cards.dart';
import 'package:salonverse/shared/design_system/sv_button.dart';
import 'package:salonverse/shared/design_system/sv_feedback_states.dart';
import 'package:salonverse/shared/design_system/sv_selection_widgets.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchBookings();
    });
  }

  void _showCancelDialog(BuildContext context, BookingModel booking) {
    final bookingProv = context.read<BookingProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Cancel Appointment?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to cancel your booking for "${booking.serviceName}" at ${booking.salonName}?',
          style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Appointment'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await bookingProv.cancelBooking(booking.id);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment cancelled successfully.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(bookingProv.error ?? 'Failed to cancel appointment.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  void _showReceiptModal(BuildContext context, BookingModel booking) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking.status.toLowerCase().contains('cancel') ? 'Cancelled Invoice' : 'Official Invoice',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    SVStatusBadge(status: booking.status, isCompact: true),
                  ],
                ),
                const SizedBox(height: 16),

                // Receipt Breakdown Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceSecondary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow('Booking ID', booking.id, isDark),
                      const SizedBox(height: 10),
                      _buildReceiptRow('Salon', booking.salonName, isDark),
                      const SizedBox(height: 10),
                      _buildReceiptRow('Treatment', booking.serviceName, isDark),
                      const SizedBox(height: 10),
                      _buildReceiptRow(
                        'Specialist',
                        booking.stylistName.isNotEmpty ? booking.stylistName : 'Any Specialist',
                        isDark,
                      ),
                      const SizedBox(height: 10),
                      _buildReceiptRow('Date & Time', '${booking.date} at ${booking.timeSlot}', isDark),
                      const SizedBox(height: 10),
                      _buildReceiptRow(
                        'Payment Method',
                        booking.paymentMethod.isNotEmpty ? booking.paymentMethod : 'Pay at Salon',
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatNPR(booking.servicePrice),
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SVButton(
                  text: 'Download PDF Receipt',
                  icon: Icons.download_rounded,
                  isFullWidth: true,
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await ReceiptPdfHelper.generateAndDownloadReceipt(
                      context: context,
                      booking: booking,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ],
    );
  }

  void _showRescheduleModal(BuildContext context, BookingModel booking) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String? selectedSlot;
    bool isRescheduling = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Container(
              padding: EdgeInsets.fromLTRB(
                18,
                16,
                18,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Reschedule Appointment',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${booking.serviceName} at ${booking.salonName}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select New Date',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SVDateScroller(
                    selectedDate: selectedDate,
                    onDateSelected: (d) {
                      setModalState(() {
                        selectedDate = d;
                        selectedSlot = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select New Time Slot',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '10:00 AM',
                      '11:00 AM',
                      '01:00 PM',
                      '02:30 PM',
                      '04:00 PM',
                      '05:30 PM',
                    ].map((slot) {
                      final isSel = selectedSlot == slot;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedSlot = slot),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.primary
                                : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceSecondary),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel
                                  ? AppColors.primary
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                          ),
                          child: Text(
                            slot,
                            style: GoogleFonts.plusJakartaSans(
                              color: isSel ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  SVButton(
                    text: 'Confirm Reschedule',
                    isFullWidth: true,
                    isLoading: isRescheduling,
                    onPressed: selectedSlot != null
                        ? () async {
                            setModalState(() => isRescheduling = true);
                            final prov = context.read<BookingProvider>();
                            final ok = await prov.rescheduleBooking(
                              booking.id,
                              selectedDate,
                              selectedSlot!,
                            );
                            setModalState(() => isRescheduling = false);
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Appointment rescheduled successfully!'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              }
                            }
                          }
                        : null,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookingProv = context.watch<BookingProvider>();
    final bookings = bookingProv.bookings;

    final upcoming = bookings.where((b) {
      final st = b.status.toLowerCase();
      return st == 'confirmed' || st == 'pending' || st == 'in_queue' || st == 'serving';
    }).toList();

    final completed = bookings.where((b) => b.status.toLowerCase() == 'completed').toList();
    final cancelled = bookings.where((b) => b.status.toLowerCase() == 'cancelled').toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'My Appointments',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500),
            tabs: [
              Tab(text: 'Upcoming (${upcoming.length})'),
              Tab(text: 'History (${completed.length})'),
              Tab(text: 'Cancelled (${cancelled.length})'),
            ],
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => bookingProv.fetchBookings(),
            color: AppColors.primary,
            child: TabBarView(
              children: [
                _buildBookingList(upcoming, 'No Upcoming Appointments', 'Schedule your next beauty treatment today.', isDark),
                _buildBookingList(completed, 'No Completed Bookings', 'Past completed appointments will appear here.', isDark),
                _buildBookingList(cancelled, 'No Cancelled Bookings', 'Cancelled appointments will appear here.', isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList(
    List<BookingModel> list,
    String emptyTitle,
    String emptyDesc,
    bool isDark,
  ) {
    if (list.isEmpty) {
      return SVEmptyState(
        icon: Icons.calendar_today_rounded,
        title: emptyTitle,
        description: emptyDesc,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 80),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final booking = list[index];
        final isActive = booking.status.toLowerCase() != 'completed' &&
            booking.status.toLowerCase() != 'cancelled';

        return SVBookingCard(
          booking: booking,
          onTap: () => _showReceiptModal(context, booking),
          onCancel: isActive ? () => _showCancelDialog(context, booking) : null,
          onReschedule: isActive ? () => _showRescheduleModal(context, booking) : null,
          onDownloadPdf: () async {
            await ReceiptPdfHelper.generateAndDownloadReceipt(
              context: context,
              booking: booking,
            );
          },
        );
      },
    );
  }
}
