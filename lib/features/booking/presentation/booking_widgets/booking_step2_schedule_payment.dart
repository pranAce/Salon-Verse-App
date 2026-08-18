import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:salonverse/app/config/api_config.dart';
import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/salons/models/salon_model.dart';
import 'package:salonverse/features/booking/services/booking_provider.dart';
import 'package:salonverse/core/utils/currency_formatter.dart';
import 'package:salonverse/shared/design_system/sv_cards.dart';
import 'package:salonverse/shared/design_system/sv_selection_widgets.dart';
import 'package:salonverse/shared/design_system/sv_button.dart';

class BookingStep2SchedulePayment extends StatefulWidget {
  final SalonModel salon;
  final ServiceModel? service;
  final StylistModel? stylist;

  const BookingStep2SchedulePayment({
    super.key,
    required this.salon,
    required this.service,
    required this.stylist,
  });

  @override
  State<BookingStep2SchedulePayment> createState() => _BookingStep2SchedulePaymentState();
}

class _BookingStep2SchedulePaymentState extends State<BookingStep2SchedulePayment> {
  final TextEditingController _promoController = TextEditingController();
  bool _isApplyingPromo = false;

  final List<Map<String, dynamic>> _paymentMethods = const [
    {'name': 'Cash', 'label': 'Pay at Salon / Cash on Delivery', 'icon': Icons.payments_outlined},
    {'name': 'Digital Wallet', 'label': 'eSewa / Khalti Wallet', 'icon': Icons.account_balance_wallet_outlined},
  ];

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _handleApplyPromo(BookingProvider prov) async {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isApplyingPromo = true);
    final basePrice = widget.service?.price ?? 500.0;
    final success = await prov.applyPromoCodeAsync(code, basePrice);
    setState(() => _isApplyingPromo = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Promo code "$code" applied! Saved Rs. ${prov.discountAmount}'),
            backgroundColor: AppColors.primary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(prov.error ?? 'Invalid promo code.'),
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
    final provider = context.watch<BookingProvider>();

    final servicePrice = widget.service?.price ?? 500.0;
    final discount = provider.discountAmount;
    final finalPrice = servicePrice - discount > 0 ? servicePrice - discount : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Appointment Summary Recap Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              boxShadow: isDark ? null : AppSpacing.softShadow(context),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 46,
                    height: 46,
                    child: widget.salon.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: ApiConfig.resolveImageUrl(widget.salon.imageUrl),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceSecondary,
                            ),
                            errorWidget: (context, url, err) => const SVFallbackLogo(
                              logoSize: 22,
                              padding: 6,
                            ),
                          )
                        : const SVFallbackLogo(
                            logoSize: 22,
                            padding: 6,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.service?.name ?? 'Treatment Service',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.salon.name} • ${widget.stylist?.name ?? "Any Specialist"}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  CurrencyFormatter.formatNPR(servicePrice),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Date Selection
          SVSectionHeader(
            title: 'Select Date',
            subtitle: 'Choose your appointment date',
          ),
          const SizedBox(height: 8),
          SVDateSelector(
            selectedDate: provider.selectedDate ?? DateTime.now(),
            onDateSelected: (date) => provider.selectDate(date),
          ),
          const SizedBox(height: 20),

          // 3. Dynamic Backend Time Slots
          SVSectionHeader(
            title: 'Available Time Slots',
            subtitle: 'Real-time slots from salon availability',
          ),
          const SizedBox(height: 8),
          SVTimeSlotSelector(
            availableSlots: provider.availableSlots,
            bookedSlots: provider.bookedSlots,
            selectedSlot: provider.selectedTime,
            isLoading: provider.isLoadingSlots,
            isSalonClosed: provider.isSalonClosed,
            closureReason: provider.closureReason,
            onSlotSelected: (slot) => provider.selectTime(slot),
          ),
          const SizedBox(height: 20),

          // 4. Promo Code Entry
          SVSectionHeader(
            title: 'Promo & Discount',
            subtitle: 'Have a coupon or voucher code?',
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: provider.appliedPromoCode ?? 'Enter Promo Code',
                      prefixIcon: const Icon(Icons.confirmation_number_outlined, size: 20),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (provider.appliedPromoCode != null)
                  TextButton(
                    onPressed: () {
                      provider.removePromoCode();
                      _promoController.clear();
                    },
                    child: Text(
                      'Remove',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  SVButton(
                    text: 'Apply',
                    size: SVButtonSize.sm,
                    isLoading: _isApplyingPromo,
                    onPressed: () => _handleApplyPromo(provider),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5. Payment Method Selection
          SVSectionHeader(
            title: 'Payment Method',
            subtitle: 'Select payment option',
          ),
          const SizedBox(height: 8),
          ..._paymentMethods.map((pm) {
            final isSel = provider.paymentMethod == pm['name'];
            return GestureDetector(
              onTap: () => provider.selectPaymentMethod(pm['name'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSel
                      ? (isDark ? const Color(0xFF301520) : AppColors.primaryTint)
                      : (isDark ? AppColors.darkSurface : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSel
                        ? AppColors.primary
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: isSel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      pm['icon'] as IconData,
                      color: isSel ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pm['name'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            pm['label'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSel ? AppColors.primary : Colors.transparent,
                        border: Border.all(
                          color: isSel
                              ? AppColors.primary
                              : (isDark ? AppColors.darkBorder : Colors.grey.shade400),
                          width: 1.5,
                        ),
                      ),
                      child: isSel
                          ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // 6. Pricing Breakdown Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                _buildPriceRow('Service Fee', CurrencyFormatter.formatNPR(servicePrice), isDark),
                if (discount > 0) ...[
                  const SizedBox(height: 8),
                  _buildPriceRow(
                    'Promo Discount (${provider.appliedPromoCode})',
                    '- ${CurrencyFormatter.formatNPR(discount)}',
                    isDark,
                    isHighlight: true,
                  ),
                ],
                const Divider(height: 20),
                _buildPriceRow(
                  'Total Payable',
                  CurrencyFormatter.formatNPR(finalPrice),
                  isDark,
                  isBold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isDark, {bool isBold = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isHighlight
                ? AppColors.success
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
        Text(
          value,
          style: isBold
              ? GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                )
              : GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                  color: isHighlight
                      ? AppColors.success
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
        ),
      ],
    );
  }
}
