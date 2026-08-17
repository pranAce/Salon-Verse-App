import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:salonverse/features/salons/models/salon_model.dart';
import 'package:salonverse/features/booking/services/booking_provider.dart';
import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/core/utils/currency_formatter.dart';
import 'package:salonverse/core/widgets/feedback_helper.dart';

import 'package:salonverse/features/booking/models/booking_slot_model.dart';

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
  State<BookingStep2SchedulePayment> createState() =>
      _BookingStep2SchedulePaymentState();
}

class _BookingStep2SchedulePaymentState
    extends State<BookingStep2SchedulePayment> {
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  List<BookingSlotModel> _filterSlotsByPeriod(
    List<BookingSlotModel> slots,
    String period,
  ) {
    return slots.where((slot) => slot.period.toLowerCase() == period.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<BookingProvider>();

    final activeDate = provider.selectedDate;
    final activeTime = provider.selectedTime;

    final dates = List.generate(
      14,
      (idx) => DateTime.now().add(Duration(days: idx)),
    );

    final availableSlots = provider.availableSlots;
    final bookedSlots = provider.bookedSlots;
    final allSlots = provider.availabilityResult?.allSlots ?? [...availableSlots, ...bookedSlots];

    final servicePrice = widget.service?.price ?? 500.0;
    final discount = provider.discountAmount;
    final finalPrice = servicePrice - discount > 0
        ? servicePrice - discount
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withAlpha(isDark ? 25 : 45),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 0 : 5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 54,
                    height: 54,
                    color: const Color(0xFFEC4899).withAlpha(15),
                    child: widget.salon.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.salon.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => const Icon(
                              Icons.storefront_rounded,
                              color: Color(0xFFEC4899),
                            ),
                          )
                        : const Icon(
                            Icons.storefront_rounded,
                            color: Color(0xFFEC4899),
                            size: 28,
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.salon.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFFEC4899),
                            size: 15,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${widget.service?.name ?? 'Salon Service'} (${widget.service?.durationMinutes ?? 30} mins) • ${widget.stylist?.name ?? 'Any Stylist'}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC4899).withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    AppCurrencyFormatter.format(servicePrice),
                    style: const TextStyle(
                      color: Color(0xFFEC4899),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFFEC4899),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "Select Date",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (activeDate != null) ...[
                const SizedBox(width: 8),
                Text(
                  "${activeDate.day}/${activeDate.month}/${activeDate.year}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEC4899),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 76,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, idx) {
                final d = dates[idx];
                final isSel =
                    activeDate != null &&
                    activeDate.year == d.year &&
                    activeDate.month == d.month &&
                    activeDate.day == d.day;

                final weekdays = [
                  "Mon",
                  "Tue",
                  "Wed",
                  "Thu",
                  "Fri",
                  "Sat",
                  "Sun",
                ];
                final weekdayStr = weekdays[d.weekday - 1];

                return GestureDetector(
                  onTap: () {
                    provider.selectDate(d);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSel
                          ? const Color(0xFFEC4899)
                          : (isDark ? const Color(0xFF1E1C1B) : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: isSel
                          ? null
                          : Border.all(
                              color: theme.colorScheme.outline.withAlpha(
                                isDark ? 20 : 40,
                              ),
                            ),
                      boxShadow: isSel
                          ? [
                              BoxShadow(
                                color: const Color(0xFFEC4899).withAlpha(45),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekdayStr,
                          style: TextStyle(
                            color: isSel
                                ? Colors.white70
                                : (isDark ? Colors.white38 : Colors.grey),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d.day.toString(),
                          style: TextStyle(
                            color: isSel
                                ? Colors.white
                                : (isDark ? Colors.white : Colors.black87),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_filled_rounded,
                      color: Color(0xFFEC4899),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "Select Time Slot",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${availableSlots.length} Available",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFEC4899),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (provider.isLoadingSlots) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: const Column(
                children: [
                  CircularProgressIndicator(color: Color(0xFFEC4899)),
                  SizedBox(height: 12),
                  Text(
                    "Checking real-time availability...",
                    style: TextStyle(color: Colors.grey, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else if (provider.error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else if (provider.isSalonClosed) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_busy_rounded, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.closureReason ??
                          "Salon is closed on this date. Please select another date.",
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else if (availableSlots.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF261D10) : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withAlpha(80)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.schedule_rounded, color: Colors.amber, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "No appointments available for this date (operating hours ended or all slots booked). Please select another date above.",
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (!provider.isLoadingSlots && !provider.isSalonClosed && provider.error == null && allSlots.isNotEmpty) ...[
            ...[
              {
                'title': 'Morning Slots',
                'icon': Icons.wb_sunny_outlined,
                'period': 'morning',
                'color': Colors.amber.shade700,
              },
              {
                'title': 'Afternoon Slots',
                'icon': Icons.wb_cloudy_outlined,
                'period': 'afternoon',
                'color': Colors.orange.shade700,
              },
              {
                'title': 'Evening Slots',
                'icon': Icons.nightlight_round,
                'period': 'evening',
                'color': Colors.indigo.shade400,
              },
            ].map((cat) {
              final categorySlots = _filterSlotsByPeriod(
                allSlots,
                cat['period'] as String,
              );
              if (categorySlots.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 14,
                          color: cat['color'] as Color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat['title'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.3,
                          ),
                      itemCount: categorySlots.length,
                      itemBuilder: (context, idx) {
                        final slotObj = categorySlots[idx];
                        final slotStr = slotObj.timeSlot.isNotEmpty ? slotObj.timeSlot : slotObj.startTime;
                        final isSel = activeTime == slotStr || activeTime == slotObj.startTime;
                        final isAvailable = slotObj.available;

                        return InkWell(
                          onTap: !isAvailable
                              ? null
                              : () {
                                  provider.selectTime(slotStr);
                                },
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: !isAvailable
                                  ? (isDark
                                        ? const Color(0xFF161514)
                                        : Colors.grey.shade200)
                                  : isSel
                                  ? const Color(0xFFEC4899)
                                  : (isDark
                                        ? const Color(0xFF1E1C1B)
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSel
                                    ? const Color(0xFFEC4899)
                                    : !isAvailable
                                    ? Colors.transparent
                                    : (isDark
                                          ? Colors.white10
                                          : Colors.grey.shade300),
                                width: isSel ? 1.5 : 1,
                              ),
                              boxShadow: isSel
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFEC4899,
                                        ).withAlpha(50),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isSel) ...[
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Flexible(
                                  child: Text(
                                    slotObj.startTime,
                                    style: TextStyle(
                                      color: !isAvailable
                                          ? (isDark
                                                ? Colors.white24
                                                : Colors.grey.shade400)
                                          : isSel
                                          ? Colors.white
                                          : (isDark
                                                ? Colors.white
                                                : Colors.black87),
                                      fontSize: 11.5,
                                      fontWeight: isSel || isAvailable
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      decoration: !isAvailable
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: provider.appliedPromoCode != null
                    ? Colors.green
                    : theme.colorScheme.outline.withAlpha(isDark ? 25 : 45),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 0 : 4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_offer_rounded,
                            color: provider.appliedPromoCode != null
                                ? Colors.green
                                : const Color(0xFFEC4899),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Promo Code & Coupons",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (provider.appliedPromoCode == null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => context.push('/profile/offers'),
                        child: const Text(
                          "View All",
                          style: TextStyle(
                            color: Color(0xFFEC4899),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                if (provider.appliedPromoCode != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withAlpha(60)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.green,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.appliedPromoCode!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.green,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      "Saved ${AppCurrencyFormatter.format(provider.discountAmount)}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.removePromoCode();
                            AppFeedback.info(context, "Promo code removed.");
                          },
                          child: const Text(
                            "Remove",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promoController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: "Enter code (e.g. SALON500)",
                            hintStyle: const TextStyle(fontSize: 12),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEC4899),
                          foregroundColor: Colors.white,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (_promoController.text.trim().isEmpty) return;
                          final ok = await provider.applyPromoCodeAsync(
                            _promoController.text.trim(),
                            servicePrice,
                          );
                          if (!context.mounted) return;
                          if (ok) {
                            AppFeedback.success(
                              context,
                              "Promo code applied successfully!",
                            );
                          } else {
                            AppFeedback.error(context, "Invalid coupon code.");
                          }
                        },
                        child: const Text(
                          "Apply",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        [
                          {"code": "SALON500", "label": "SALON500 (-Rs.500)"},
                          {"code": "GLOW20", "label": "GLOW20 (-20%)"},
                          {"code": "BEAUTY50", "label": "BEAUTY50 (-50%)"},
                        ].map((coupon) {
                          return GestureDetector(
                            onTap: () async {
                              _promoController.text = coupon["code"]!;
                              await provider.applyPromoCodeAsync(
                                coupon["code"]!,
                                servicePrice,
                              );
                              if (context.mounted) {
                                AppFeedback.success(
                                  context,
                                  "Applied ${coupon['code']}!",
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC4899).withAlpha(12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFEC4899).withAlpha(40),
                                ),
                              ),
                              child: Text(
                                coupon["label"]!,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEC4899),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: Color(0xFFEC4899),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "Payment Method",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ...[
            {
              'key': 'Cash',
              'title': 'Pay at Salon (Cash / QR)',
              'desc': 'Pay directly at counter after service',
              'icon': Icons.storefront_rounded,
              'color': const Color(0xFFEC4899),
            },
            {
              'key': 'eSewa',
              'title': 'eSewa Mobile Wallet',
              'desc': 'Instant checkout with eSewa Nepal',
              'icon': Icons.account_balance_wallet_rounded,
              'color': const Color(0xFF60BB46),
            },
            {
              'key': 'Khalti',
              'title': 'Khalti Digital Wallet',
              'desc': 'Fast & secure digital payment with Khalti',
              'icon': Icons.wallet_rounded,
              'color': const Color(0xFF5C2D91),
            },
          ].map((m) {
            final key = m['key'] as String;
            final isSel = provider.paymentMethod == key;
            final color = m['color'] as Color;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isSel
                    ? color.withAlpha(10)
                    : (isDark ? const Color(0xFF1E1C1B) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSel
                      ? color
                      : theme.colorScheme.outline.withAlpha(isDark ? 20 : 40),
                  width: isSel ? 1.8 : 1,
                ),
                boxShadow: isSel
                    ? [
                        BoxShadow(
                          color: color.withAlpha(30),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: InkWell(
                onTap: () => provider.selectPaymentMethod(key),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          m['icon'] as IconData,
                          color: color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['title'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              m['desc'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.white60
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSel
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSel
                            ? color
                            : (isDark ? Colors.white38 : Colors.grey),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1C1B) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withAlpha(isDark ? 25 : 45),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Price Breakdown",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Service Fee (${widget.service?.name ?? 'Service'})",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppCurrencyFormatter.format(servicePrice),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Platform & Booking Fee",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "FREE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                if (discount > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Voucher Discount (${provider.appliedPromoCode})",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "- ${AppCurrencyFormatter.format(discount)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Total Amount Payable",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppCurrencyFormatter.format(finalPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Color(0xFFEC4899),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
