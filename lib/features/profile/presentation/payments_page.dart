import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonverse/features/booking/services/booking_provider.dart';
import 'package:salonverse/core/utils/receipt_pdf_helper.dart';
import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/core/widgets/empty_state.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String txnId =
        "TXN-${booking.id.length >= 6 ? booking.id.substring(0, 6).toUpperCase() : booking.id.toUpperCase()}-${booking.paymentMethod.toUpperCase()}";
    final double amount = (booking.servicePrice as num?)?.toDouble() ?? 500.0;
    final bool isPaid = booking.paymentStatus.toLowerCase() == 'completed';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1C1B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPaid
                        ? Colors.green.withAlpha(20)
                        : Colors.orange.withAlpha(20),
                  ),
                  child: Icon(
                    isPaid
                        ? Icons.check_circle_rounded
                        : Icons.access_time_rounded,
                    color: isPaid ? Colors.green : Colors.orange,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  isPaid ? "Payment Receipt" : "Payment Pending",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  txnId,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              _buildReceiptRow("Salon", booking.salonName),
              _buildReceiptRow("Service", booking.serviceName),
              _buildReceiptRow(
                "Date & Time",
                "${booking.date} at ${booking.timeSlot}",
              ),
              _buildReceiptRow("Payment Method", booking.paymentMethod),
              _buildReceiptRow(
                "Status",
                isPaid ? "Paid in Full" : "Pay at Salon",
                valueColor: isPaid ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              _buildReceiptRow(
                "Total Paid",
                "Rs. ${amount.round()}",
                isBold: true,
                valueColor: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ReceiptPdfHelper.generateAndDownloadReceipt(
                    context: context,
                    booking: booking,
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Download Receipt PDF",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
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
        totalSpent += b.servicePrice;
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "My Payments",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      const Color(0xFFC39B4B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withAlpha(40),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TOTAL SPENT",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white70,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Rs. ${totalSpent.round()}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSummaryBadge(
                          "eSewa",
                          Icons.account_balance_wallet_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildSummaryBadge("Khalti", Icons.wallet_rounded),
                        const SizedBox(width: 8),
                        _buildSummaryBadge("Cash", Icons.money_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: ['All', 'Completed', 'Pending'].map((filter) {
                  final isSel = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setState(() => _selectedFilter = filter);
                      },
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSel
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: bookingProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                  ? EmptyState(
                      icon: Icons.receipt_long_rounded,
                      title: "No transactions found",
                      subtitle:
                          "Your payment records and receipts will appear here.",
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final b = filtered[index];
                        return _buildPaymentCard(theme, isDark, b);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(ThemeData theme, bool isDark, dynamic b) {
    final bool isPaid = b.paymentStatus.toLowerCase() == 'completed';
    final String method = b.paymentMethod.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2A29) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 0 : 4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isPaid
                ? Colors.green.withAlpha(20)
                : Colors.orange.withAlpha(20),
            child: Icon(
              method.contains('ESEWA') || method.contains('KHALTI')
                  ? Icons.account_balance_wallet_rounded
                  : Icons.payments_rounded,
              color: isPaid ? Colors.green : Colors.orange,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.serviceName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "${b.salonName} • $method",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Text(
                  "${b.date} • ${b.timeSlot}",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Rs. ${b.servicePrice.round()}",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: isPaid
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.orange,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _showReceiptModal(b),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? Colors.green.withAlpha(20)
                        : Colors.orange.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isPaid ? "Receipt" : "Pending",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isPaid ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
