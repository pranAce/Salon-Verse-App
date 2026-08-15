import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:salonverse/models/offer_model.dart';
import 'package:salonverse/services/app_service.dart';
import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/widgets/feedback_helper.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  String _selectedCategory = "All Offers";
  final TextEditingController _customCodeController = TextEditingController();

  List<OfferModel> _offers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  @override
  void dispose() {
    _customCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AppService.instance.getOffers();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result is Success<List<OfferModel>>) {
          _offers = result.data;
        } else {
          _errorMessage = (result as Failure).message;
        }
      });
    }
  }

  static const List<OfferModel> fallbackOffers = [
    OfferModel(
      id: "offer_salon500",
      code: "SALON500",
      title: "Flat Rs. 500 Welcome Discount",
      description:
          "Get Rs. 500 off on your salon bookings above Rs. 1000. Valid across all verified salons in Nepal.",
      discountType: "fixed",
      discountValue: 500.0,
      minOrderAmount: 1000.0,
      isActive: true,
      badgeColor: Color(0xFFEC4899),
      category: "Discounts",
      icon: Icons.card_giftcard_rounded,
    ),
    OfferModel(
      id: "offer_glow20",
      code: "GLOW20",
      title: "20% Off Skincare & Spa Sessions",
      description:
          "Enjoy 20% off on all facial, spa, massage, and bridal packages across partner salons.",
      discountType: "percentage",
      discountValue: 20.0,
      minOrderAmount: 500.0,
      maxDiscount: 500.0,
      isActive: true,
      badgeColor: Color(0xFF8B5CF6),
      category: "Spa Packages",
      icon: Icons.spa_rounded,
    ),
    OfferModel(
      id: "offer_beauty50",
      code: "BEAUTY50",
      title: "First Booking 50% Special",
      description:
          "First time trying SalonVerse? Claim 50% discount up to Rs. 500 on haircuts and styling.",
      discountType: "percentage",
      discountValue: 50.0,
      minOrderAmount: 300.0,
      maxDiscount: 500.0,
      isActive: true,
      badgeColor: Color(0xFF10B981),
      category: "Discounts",
      icon: Icons.content_cut_rounded,
    ),
    OfferModel(
      id: "offer_weekend15",
      code: "WEEKEND15",
      title: "Weekend Styling Bonanza",
      description:
          "Book any weekend appointment (Friday - Sunday) and get an instant 15% discount automatically.",
      discountType: "percentage",
      discountValue: 15.0,
      minOrderAmount: 400.0,
      isActive: true,
      badgeColor: Color(0xFFF59E0B),
      category: "Cashback",
      icon: Icons.celebration_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF111827);
    final secondaryTextColor = isDark
        ? Colors.white70
        : const Color(0xFF4B5563);
    final cardBgColor = isDark ? const Color(0xFF1E1C1B) : Colors.white;

    final displayOffers = _offers.isNotEmpty ? _offers : fallbackOffers;

    final filteredOffers = displayOffers.where((offer) {
      if (!offer.isActive) return false;
      if (_selectedCategory == "All Offers") return true;
      if (_selectedCategory == "Discounts") {
        return offer.category == "Discounts" ||
            offer.discountType == 'percentage';
      }
      if (_selectedCategory == "Spa Packages") {
        return offer.category == "Spa Packages";
      }
      if (_selectedCategory == "Cashback") {
        return offer.category == "Cashback" || offer.discountType == 'fixed';
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF090808)
          : const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF090808) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Exclusive Offers & Deals",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            onPressed: _loadOffers,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadOffers,
          color: const Color(0xFFEC4899),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFEC4899),
                        Color(0xFFF43F5E),
                        Color(0xFFFB923C),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEC4899).withAlpha(60),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "HOT DEALS",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Save Up to 50% On\nYour Favorite Salons",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Copy codes below and apply them during booking checkout for instant savings.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2C2A29)
                          : Colors.grey.shade200,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 0 : 5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Have a Secret Voucher Code?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF141312)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _customCodeController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1.0,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter voucher code...",
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.grey.shade400,
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.confirmation_num_outlined,
                                    size: 20,
                                    color: Color(0xFFEC4899),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEC4899),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              final code = _customCodeController.text
                                  .trim()
                                  .toUpperCase();
                              if (code.isEmpty) return;
                              Clipboard.setData(ClipboardData(text: code));
                              AppFeedback.success(
                                context,
                                "Voucher code '$code' copied! Apply during checkout.",
                              );
                            },
                            child: const Text(
                              "Copy Code",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Available Coupons & Vouchers",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: primaryTextColor,
                      ),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFEC4899),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        [
                          "All Offers",
                          "Discounts",
                          "Spa Packages",
                          "Cashback",
                        ].map((cat) {
                          final isSel = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSel,
                              onSelected: (val) {
                                if (val) {
                                  setState(() => _selectedCategory = cat);
                                }
                              },
                              selectedColor: const Color(0xFFEC4899),
                              backgroundColor: isDark
                                  ? const Color(0xFF1E1C1B)
                                  : Colors.white,
                              labelStyle: TextStyle(
                                color: isSel
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.white70
                                          : Colors.black87),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              side: BorderSide(
                                color: isSel
                                    ? const Color(0xFFEC4899)
                                    : (isDark
                                          ? const Color(0xFF2C2A29)
                                          : Colors.grey.shade300),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                if (_errorMessage != null && _offers.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.withAlpha(40)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Showing offline promotions. Server: $_errorMessage",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (filteredOffers.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_offer_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No active offers available in this category.",
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...filteredOffers.map(
                    (offer) => _buildOfferCard(
                      context,
                      isDark,
                      primaryTextColor,
                      secondaryTextColor,
                      cardBgColor,
                      offer,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(
    BuildContext context,
    bool isDark,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color cardBgColor,
    OfferModel offer,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? offer.badgeColor.withAlpha(80)
              : offer.badgeColor.withAlpha(60),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 0 : 6),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: offer.badgeColor.withAlpha(isDark ? 35 : 20),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(offer.icon, color: offer.badgeColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      offer.discountLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: offer.badgeColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black38 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    offer.expiryLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  offer.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: secondaryTextColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF141312)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2C2A29)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: Text(
                          offer.code,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: offer.badgeColor,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: offer.badgeColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                            icon: const Icon(Icons.copy_rounded, size: 16),
                            label: const Text(
                              "Copy",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: offer.code),
                              );
                              AppFeedback.success(
                                context,
                                "Promo code '${offer.code}' copied to clipboard!",
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: offer.badgeColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 11,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: offer.code),
                              );
                              AppFeedback.success(
                                context,
                                "Promo code '${offer.code}' applied! Select your salon to book.",
                              );
                              context.go('/home');
                            },
                            child: const Text(
                              "Apply & Book",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
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
        ],
      ),
    );
  }
}
