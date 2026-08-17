import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:salonverse/features/loyalty/models/offer_model.dart';
import 'package:salonverse/features/loyalty/services/offer_service.dart';
import 'package:salonverse/features/home/services/settings_provider.dart';
import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/widgets/feedback_helper.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  final OfferService _offerService = OfferService();

  String _selectedCategory = "All Offers";
  List<OfferModel> _offers = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _categories = [
    "All Offers",
    "Hair",
    "Beauty",
    "Nails",
    "Spa",
    "Makeup",
  ];

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _offerService.getOffers();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result is Success<List<OfferModel>>) {
          // Filter out expired offers
          _offers = result.data.where((o) => o.isActive && o.expiryLabel != "Expired").toList();
        } else if (result is Failure<List<OfferModel>>) {
          _errorMessage = result.message;
        }
      });
    }
  }

  void _showOfferDetails(BuildContext context, OfferModel offer) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Handle Indicator
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Offer Banner & Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC4899).withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(offer.icon, color: const Color(0xFFEC4899), size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEC4899),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              offer.discountLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            offer.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Salon & Location Info
                Row(
                  children: [
                    const Icon(Icons.storefront_rounded, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      offer.primarySalonName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const Spacer(),
                    const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFEC4899)),
                    const SizedBox(width: 4),
                    Text(
                      offer.primaryLocation,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const Divider(height: 28),

                // Promo Code Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141414) : Colors.pink.withAlpha(10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEC4899).withAlpha(40)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PROMO CODE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.grey,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            offer.code,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: Color(0xFFEC4899),
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEC4899),
                          side: const BorderSide(color: Color(0xFFEC4899)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: offer.code));
                          AppFeedback.success(ctx, 'Promo code ${offer.code} copied!');
                        },
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Copy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Description & Terms
                if (offer.description.isNotEmpty) ...[
                  const Text(
                    'Offer Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    offer.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                ],

                const Text(
                  'Terms & Conditions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                if (offer.minOrderAmount > 0)
                  _buildTermItem('Minimum spend required: NPR ${offer.minOrderAmount.toInt()}'),
                if (offer.maxDiscount != null)
                  _buildTermItem('Maximum discount capped at NPR ${offer.maxDiscount!.toInt()}'),
                _buildTermItem(offer.expiryLabel),
                _buildTermItem('Valid for customer bookings at applicable partner salons'),

                const SizedBox(height: 24),

                // CTA Action
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEC4899),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<SettingsProvider>().setPage(1); // Salons Tab
                      context.go('/salon-tab');
                    },
                    child: const Text(
                      'Book Now with Offer',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFFEC4899), fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
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

    final filteredOffers = _offers.where((offer) {
      if (_selectedCategory == "All Offers") return true;
      final catLower = offer.category.toLowerCase();
      final selLower = _selectedCategory.toLowerCase();
      return catLower.contains(selLower) ||
          offer.applicableCategories.any((c) => c.toLowerCase().contains(selLower));
    }).toList();

    OfferModel? featuredOffer;
    if (filteredOffers.isNotEmpty) {
      featuredOffer = filteredOffers.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offers', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadOffers,
          ),
        ],
      ),
      body: _isLoading
          ? _buildSkeletonLoading(isDark)
          : _errorMessage != null
              ? _buildErrorState(theme)
              : RefreshIndicator(
                  onRefresh: _loadOffers,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Header & Location Context
                        const Text(
                          'Discover exclusive offers from salons near you.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Icon(Icons.location_on_rounded, size: 14, color: Color(0xFFEC4899)),
                            SizedBox(width: 4),
                            Text(
                              'Kathmandu',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFFEC4899),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 2. Horizontal Category Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories.map((cat) {
                              final isSelected = _selectedCategory == cat;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(cat),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFFEC4899),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => _selectedCategory = cat);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 3. Featured Offer Section
                        if (featuredOffer != null) ...[
                          const Text(
                            'Featured Offer',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          _buildFeaturedCard(context, featuredOffer, isDark),
                          const SizedBox(height: 28),
                        ],

                        // 4. Best Offers List Section
                        Text(
                          'Best Offers Near You',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),

                        filteredOffers.isEmpty
                            ? _buildEmptyState(context, isDark)
                            : Column(
                                children: [
                                  for (final offer in filteredOffers) ...[
                                    OfferCard(
                                      offer: offer,
                                      onTap: () => _showOfferDetails(context, offer),
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, OfferModel offer, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF241528), const Color(0xFF140C18)]
              : [const Color(0xFF831843), const Color(0xFF9D174D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withAlpha(isDark ? 30 : 60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withAlpha(isDark ? 20 : 40),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background Decorative Pattern Circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(12),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(8),
              ),
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        offer.discountLabel,
                        style: const TextStyle(
                          color: Color(0xFFBE185D),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withAlpha(40)),
                      ),
                      child: Text(
                        offer.code,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.white70, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            offer.expiryLabel,
                            style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Title & Icon Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.storefront_rounded, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                offer.primarySalonName,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.location_on_rounded, size: 14, color: Colors.white70),
                              const SizedBox(width: 2),
                              Text(
                                offer.primaryLocation,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(40)),
                      ),
                      child: Icon(offer.icon, color: Colors.white, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Bottom Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (offer.minOrderAmount > 0)
                      Text(
                        'Min. spend NPR ${offer.minOrderAmount.toInt()}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                      )
                    else
                      const Text(
                        'No minimum spend required',
                        style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFBE185D),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () => _showOfferDetails(context, offer),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                      label: const Text('View Offer', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withAlpha(40)),
      ),
      child: Column(
        children: [
          const Icon(Icons.local_offer_outlined, size: 44, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'No offers available',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            "There aren't any offers available near you right now.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEC4899),
              side: const BorderSide(color: Color(0xFFEC4899)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              context.read<SettingsProvider>().setPage(1);
              context.go('/salon-tab');
            },
            child: const Text('Explore Salons', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 44, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'Unable to load offers.',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEC4899)),
            onPressed: _loadOffers,
            child: const Text('Try Again', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 16, width: 220, color: Colors.grey.withAlpha(30)),
          const SizedBox(height: 20),
          Container(height: 140, width: double.infinity, decoration: BoxDecoration(color: Colors.grey.withAlpha(20), borderRadius: BorderRadius.circular(20))),
          const SizedBox(height: 28),
          Container(height: 18, width: 160, color: Colors.grey.withAlpha(30)),
          const SizedBox(height: 12),
          for (int i = 0; i < 3; i++) ...[
            Container(height: 100, width: double.infinity, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.grey.withAlpha(20), borderRadius: BorderRadius.circular(16))),
          ],
        ],
      ),
    );
  }
}

// 5. Reusable OfferCard Component
class OfferCard extends StatelessWidget {
  final OfferModel offer;
  final VoidCallback onTap;

  const OfferCard({
    super.key,
    required this.offer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(isDark ? 20 : 40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  offer.discountLabel,
                  style: const TextStyle(
                    color: Color(0xFFEC4899),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  offer.code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                offer.expiryLabel,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            offer.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.storefront_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                offer.primarySalonName,
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFFEC4899)),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  offer.primaryLocation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (offer.minOrderAmount > 0)
                Text(
                  'Min. spend NPR ${offer.minOrderAmount.toInt()}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                )
              else
                const SizedBox.shrink(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC4899),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: onTap,
                child: const Text('View Offer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
