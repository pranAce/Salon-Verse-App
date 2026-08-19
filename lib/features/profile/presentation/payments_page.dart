import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/booking/services/booking_provider.dart';
import 'package:salonverse/core/utils/currency_formatter.dart';
import 'package:salonverse/core/utils/receipt_pdf_helper.dart';
import 'package:salonverse/core/widgets/sv_button.dart';
import 'package:salonverse/core/widgets/sv_selection_widgets.dart';
import 'package:salonverse/core/widgets/sv_feedback_states.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchBookings();
    });
  }

  void _showReceiptModal(dynamic booking) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isPaid = booking.paymentStatus.toLowerCase() == 'completed';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.sheetRadius),
          ),
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
            const SizedBox(height: 18),
            Text(
              isPaid ? 'Payment Receipt' : 'Payment Pending',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Booking Ref: #${booking.id.substring(0, booking.id.length > 8 ? 8 : booking.id.length).toUpperCase()}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceElevated
                    : AppColors.lightSurfaceSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildReceiptRow('Salon Venue', booking.salonName, isDark),
                  const SizedBox(height: 8),
                  _buildReceiptRow('Treatment', booking.serviceName, isDark),
                  const SizedBox(height: 8),
                  _buildReceiptRow(
                    'Date & Time',
                    '${booking.date} at ${booking.timeSlot}',
                    isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildReceiptRow('Mode', booking.paymentMethod, isDark),
                  const Divider(height: 20),
                  _buildReceiptRow(
                    'Total Paid',
                    CurrencyFormatter.formatNPR(booking.finalAmount),
                    isDark,
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SVButton(
              text: 'Download PDF Receipt',
              isFullWidth: true,
              icon: Icons.download_rounded,
              onPressed: () {
                Navigator.pop(ctx);
                ReceiptPdfHelper.generateAndOpenReceipt(booking);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value,
    bool isDark, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: isBold
              ? GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                )
              : GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookingProvider = context.watch<BookingProvider>();
    final bookings = bookingProvider.bookings;

    final filtered = bookings.where((b) {
      if (_selectedFilter == 'Completed') {
        return b.paymentStatus.toLowerCase() == 'completed';
      }
      if (_selectedFilter == 'Pending') {
        return b.paymentStatus.toLowerCase() != 'completed';
      }
      return true;
    }).toList();

    double totalSpent = 0.0;
    for (var b in bookings) {
      if (b.paymentStatus.toLowerCase() == 'completed') {
        totalSpent += b.finalAmount;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Payments',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppSpacing.glowShadow(
                    AppColors.primary,
                    opacity: 0.3,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL EXPENDITURE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white70,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatNPR(totalSpent),
                      style: GoogleFonts.outfit(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: ['All', 'Completed', 'Pending'].map((f) {
                  final isSel = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SVCFilterChip(
                      label: f,
                      isSelected: isSel,
                      onSelected: () => setState(() => _selectedFilter = f),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: filtered.isEmpty
                  ? const SVEmptyState(
                      icon: Icons.receipt_long_rounded,
                      title: 'No Payment Records',
                      description:
                          'Your payment history and invoices will be listed here.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final b = filtered[index];
                        final isPaid =
                            b.paymentStatus.toLowerCase() == 'completed';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                            boxShadow: isDark
                                ? null
                                : AppSpacing.softShadow(context),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: isPaid
                                    ? const Color(0xFF10B981).withAlpha(20)
                                    : const Color(0xFFF59E0B).withAlpha(20),
                                child: Icon(
                                  Icons.receipt_rounded,
                                  color: isPaid
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.serviceName,
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${b.salonName} • ${b.paymentMethod}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${b.date} • ${b.timeSlot}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: isDark
                                            ? AppColors.darkTextTertiary
                                            : AppColors.lightTextTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.formatNPR(b.finalAmount),
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _showReceiptModal(b),
                                    child: SVStatusBadge(
                                      status: b.paymentStatus,
                                      isCompact: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
