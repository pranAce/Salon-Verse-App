import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:salonverse/app/config/api_config.dart';
import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/auth/services/auth_provider.dart';
import 'package:salonverse/features/booking/services/booking_provider.dart';
import 'package:salonverse/features/salons/services/salon_provider.dart';
import 'package:salonverse/features/salons/models/salon_model.dart';
import 'package:salonverse/features/salons/models/review_model.dart';
import 'package:salonverse/features/salons/services/review_service.dart';
import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/utils/currency_formatter.dart';
import 'package:salonverse/shared/design_system/sv_button.dart';
import 'package:salonverse/shared/design_system/sv_cards.dart';
import 'package:salonverse/shared/design_system/sv_selection_widgets.dart';
import 'package:salonverse/shared/design_system/sv_feedback_states.dart';

class SalonDetailScreen extends StatefulWidget {
  final String salonId;
  final SalonModel? preloadedSalon;

  const SalonDetailScreen({
    super.key,
    required this.salonId,
    this.preloadedSalon,
  });

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen> {
  SalonModel? _salon;
  bool _isLoadingSalon = false;
  String _selectedCategory = 'All';
  ServiceModel? _selectedService;
  List<ReviewModel> _reviews = [];

  @override
  void initState() {
    super.initState();
    if (widget.preloadedSalon != null) {
      _salon = widget.preloadedSalon;
      _initSelections();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFullSalonDetails();
      _loadReviews();
    });
  }

  Future<void> _loadFullSalonDetails() async {
    if (_salon == null || _salon!.services.isEmpty) {
      setState(() => _isLoadingSalon = true);
    }
    final fullSalon = await context.read<SalonProvider>().fetchSalonDetails(widget.salonId);
    if (mounted) {
      setState(() {
        _isLoadingSalon = false;
        if (fullSalon != null) {
          _salon = fullSalon;
          _initSelections();
        }
      });
    }
  }

  Future<void> _loadReviews() async {
    final res = await ReviewService().getReviewsForSalon(widget.salonId);
    if (mounted && res is Success<List<ReviewModel>>) {
      setState(() {
        _reviews = res.data;
      });
    }
  }

  void _initSelections() {
    if (_salon != null && _selectedService == null) {
      if (_salon!.services.isNotEmpty) {
        _selectedService = _salon!.services.first;
      }
    }
  }

  void _startBooking([ServiceModel? service]) {
    if (_salon == null) return;
    final bookingProv = context.read<BookingProvider>();
    final targetService = service ?? _selectedService;

    if (targetService != null) {
      bookingProv.startBookingFlow(_salon!, targetService);
    } else {
      bookingProv.startBookingFlowForSalon(_salon!);
    }
    context.push('/booking-flow');
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMapDirections(double lat, double lng, String name) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (_isLoadingSalon && _salon == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Salon Details', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_salon == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Salon Details', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        ),
        body: SVEmptyState(
          icon: Icons.storefront_outlined,
          title: 'Salon Unavailable',
          description: 'Could not load the salon details. Please try again.',
          actionLabel: 'Go Back',
          onAction: () => Navigator.pop(context),
        ),
      );
    }

    final isFav = user?.favoriteSalons.contains(_salon!.id) ?? false;
    final resolvedImageUrl = ApiConfig.resolveImageUrl(_salon!.imageUrl);

    final categories = ['All', ..._salon!.services.map((s) => s.category).toSet()];

    final filteredServices = _selectedCategory == 'All'
        ? _salon!.services
        : _salon!.services.where((s) => s.category == _selectedCategory).toList();

    return Scaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 1. Hero Image Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SVIconButton(
                icon: Icons.arrow_back_rounded,
                size: 38,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SVIconButton(
                  icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? AppColors.primary : null,
                  size: 38,
                  onPressed: () {
                    auth.toggleFavorite(_salon!.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFav ? 'Removed from favorites' : 'Added to favorites!',
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: resolvedImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceSecondary,
                    ),
                    errorWidget: (context, url, err) => const SVFallbackLogo(
                      width: double.infinity,
                      height: double.infinity,
                      logoSize: 52,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withAlpha(80),
                          Colors.transparent,
                          Colors.black.withAlpha(200),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 18,
                    right: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_salon!.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFF92400E)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withAlpha(115),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('👑', style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                  'VERIFIED PRO SALON',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          )

                        else if (_salon!.isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'VERIFIED SALON',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                        Text(
                          _salon!.name,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Salon Metadata & Quick Actions
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 4),
                                Text(
                                  _salon!.rating > 0 ? _salon!.rating.toStringAsFixed(1) : '4.8',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${_salon!.reviewsCount > 0 ? _salon!.reviewsCount : 12} reviews)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _salon!.priceRange.isNotEmpty ? _salon!.priceRange : 'Moderate',
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 15, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${_salon!.address}, ${_salon!.city}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Quick Action Buttons
                  Row(
                    children: [
                      if (_salon!.phone.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            icon: const Icon(Icons.phone_outlined, size: 15, color: AppColors.primary),
                            label: Text('Call', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                            onPressed: () => _makePhoneCall(_salon!.phone),
                          ),
                        ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        icon: const Icon(Icons.directions_outlined, size: 15, color: AppColors.primary),
                        label: Text('Directions', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                        onPressed: () => _openMapDirections(_salon!.lat, _salon!.lng, _salon!.name),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Category Filter Chips
          if (categories.length > 1)
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SVCFilterChip(
                        label: cat,
                        isSelected: isSel,
                        onSelected: () => setState(() => _selectedCategory = cat),
                      ),
                    );
                  },
                ),
              ),
            ),

          // 4. Services Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: SVSectionHeader(
                title: 'Available Treatments & Services',
                subtitle: 'Tap any service to select or book instantly',
              ),
            ),
          ),

          // 5. Services List
          if (filteredServices.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: SVEmptyState(
                  icon: Icons.content_cut_rounded,
                  title: 'No Services Available',
                  description: 'Services for this category will be updated shortly.',
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final service = filteredServices[index];
                    final isSel = _selectedService?.id == service.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedService = service);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSel
                              ? (isDark ? AppColors.primaryTintDark : AppColors.primaryTint)
                              : (isDark ? AppColors.darkSurface : Colors.white),
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                          border: Border.all(
                            color: isSel
                                ? AppColors.primary
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: isSel ? 1.5 : 1.0,
                          ),
                          boxShadow: isDark ? null : AppSpacing.softShadow(context),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${service.durationMinutes} mins • ${service.category}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                                    ),
                                  ),
                                  if (service.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      service.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.formatNPR(service.price),
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  height: 32,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSel ? AppColors.primary : (isDark ? AppColors.darkSurfaceElevated : AppColors.primaryTint),
                                      foregroundColor: isSel ? Colors.white : AppColors.primary,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      setState(() => _selectedService = service);
                                      _startBooking(service);
                                    },
                                    child: Text(
                                      isSel ? 'Selected' : 'Book',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: filteredServices.length,
                ),
              ),
            ),

          // 6. Specialists Section
          if (_salon!.stylists.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                child: SVSectionHeader(
                  title: 'Our Specialists',
                  subtitle: 'Experienced stylists and beauticians',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _salon!.stylists.length,
                  itemBuilder: (context, index) {
                    final stylist = _salon!.stylists[index];
                    return Container(
                      width: 125,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: stylist.imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: ApiConfig.resolveImageUrl(stylist.imageUrl),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: isDark ? AppColors.darkSurfaceElevated : AppColors.primaryTint,
                                      ),
                                      errorWidget: (context, url, err) => const SVFallbackLogo(
                                        width: 40,
                                        height: 40,
                                        logoSize: 18,
                                        padding: 6,
                                      ),
                                    )
                                  : const SVFallbackLogo(
                                      width: 40,
                                      height: 40,
                                      logoSize: 18,
                                      padding: 6,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            stylist.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            stylist.specialty.isNotEmpty ? stylist.specialty : 'Specialist',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          // 7. About & Hours Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: SVSectionHeader(
                title: 'About & Hours',
                subtitle: 'Venue details and business schedule',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _salon!.description.isNotEmpty
                          ? _salon!.description
                          : 'Experience premier salon & beauty care with trained professionals in a hygienic, modern environment.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        height: 1.45,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildHoursRow('Monday - Friday', '09:00 AM - 08:00 PM', isDark),
                    const Divider(height: 12),
                    _buildHoursRow('Saturday', '08:00 AM - 09:00 PM', isDark, isHighlighted: true),
                    const Divider(height: 12),
                    _buildHoursRow('Sunday', '09:00 AM - 07:00 PM', isDark),
                  ],
                ),
              ),
            ),
          ),

          // 8. Reviews Section
          if (_reviews.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                child: SVSectionHeader(
                  title: 'Customer Reviews (${_reviews.length})',
                  subtitle: 'Feedback from verified visitors',
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final r = _reviews[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                r.userName,
                                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 2),
                                  Text(
                                    r.rating.toStringAsFixed(1),
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFFF59E0B)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (r.comment.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              r.comment,
                              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  childCount: _reviews.take(5).length,
                ),
              ),
            ),
          ],

          // Bottom spacing for sticky bar
          const SliverToBoxAdapter(
            child: SizedBox(height: 90),
          ),
        ],
      ),

      // Compact, Sleek Sticky Bottom Booking Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 35 : 10),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                // Left: Selected service name + price
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedService != null ? _selectedService!.name : 'Select a Treatment',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedService != null
                            ? CurrencyFormatter.formatNPR(_selectedService!.price)
                            : 'From Rs. 200',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Right: Sleek, compact Book Appointment Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _startBooking(),
                  child: Text(
                    'Book Appointment',
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHoursRow(String days, String hours, bool isDark, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          days,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
            color: isHighlighted ? AppColors.primary : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
        Text(
          hours,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w400,
            color: isHighlighted ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
      ],
    );
  }
}
