import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/app/config/api_config.dart';
import 'package:salonverse/features/auth/services/auth_provider.dart';
import 'package:salonverse/features/salons/services/salon_provider.dart';
import 'package:salonverse/features/salons/models/nearby_service_model.dart';
import 'package:salonverse/features/booking/services/booking_provider.dart';
import 'package:salonverse/features/loyalty/models/offer_model.dart';
import 'package:salonverse/features/loyalty/services/offer_service.dart';
import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/utils/currency_formatter.dart';
import 'package:salonverse/shared/design_system/sv_button.dart';
import 'package:salonverse/shared/design_system/sv_cards.dart';
import 'package:salonverse/shared/design_system/sv_selection_widgets.dart';
import 'package:salonverse/shared/design_system/sv_feedback_states.dart';
import 'package:salonverse/features/loyalty/services/loyalty_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String _liveGpsLocation = 'Locating...';
  bool _isFetchingGps = false;
  double? _userLat;
  double? _userLng;

  List<OfferModel> _featuredOffers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLiveGpsAndSalons();
      _loadOffers();
      context.read<BookingProvider>().fetchBookings();
      context.read<LoyaltyProvider>().loadLoyaltyData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchLiveGpsAndSalons();
    }
  }

  Future<void> _loadOffers() async {
    final res = await OfferService().getOffers();
    if (mounted) {
      setState(() {
        if (res is Success<List<OfferModel>>) {
          _featuredOffers = res.data.where((o) => o.isActive && o.expiryLabel != "Expired").toList();
        }
      });
    }
  }

  Future<void> _fetchLiveGpsAndSalons() async {
    if (_isFetchingGps) return;
    setState(() {
      _isFetchingGps = true;
      _liveGpsLocation = 'Locating...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _liveGpsLocation = 'Enable GPS');
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() => _liveGpsLocation = 'Location Denied');
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _liveGpsLocation = 'Permission Blocked');
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _userLat = position.latitude;
      _userLng = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final locality = place.locality ?? place.subAdministrativeArea ?? 'Kathmandu';
        final subLocality = place.subLocality ?? place.street ?? '';
        final formatted = subLocality.isNotEmpty && !subLocality.contains('+')
            ? "$subLocality, $locality"
            : "$locality, Nepal";

        if (mounted) {
          setState(() => _liveGpsLocation = formatted);
        }
      }

      if (mounted) {
        final salonProv = context.read<SalonProvider>();
        salonProv.fetchSalons(lat: _userLat, lng: _userLng, forceRefresh: true);
        salonProv.fetchNearbyServices(lat: _userLat, lng: _userLng);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _liveGpsLocation = 'Kathmandu, Nepal';
          _userLat = 27.7172;
          _userLng = 85.3240;
        });
        final salonProv = context.read<SalonProvider>();
        salonProv.fetchSalons(lat: 27.7172, lng: 85.3240, forceRefresh: true);
        salonProv.fetchNearbyServices(lat: 27.7172, lng: 85.3240);
      }
    } finally {
      if (mounted) setState(() => _isFetchingGps = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final salonProv = context.watch<SalonProvider>();
    final bookingProv = context.watch<BookingProvider>();

    final user = auth.currentUser;
    final firstName = user != null && user.name.trim().isNotEmpty
        ? user.name.trim().split(' ').first
        : 'Guest';

    final salons = salonProv.salons;
    final featuredSalons = salonProv.featuredSalons.isNotEmpty
        ? salonProv.featuredSalons
        : salons.take(4).toList();
    final nearbyServices = salonProv.nearbyServices;
    final trendingServices = List<NearbyServiceModel>.from(nearbyServices);
    if (trendingServices.length > 2) {
      trendingServices.shuffle(Random(salons.length));
    }

    // Active appointment if any
    final upcomingList = bookingProv.bookings.where((b) {
      final st = b.status.toLowerCase();
      return st != 'completed' && st != 'cancelled' && st != 'no_show';
    }).toList();
    final nextBooking = upcomingList.isNotEmpty ? upcomingList.first : null;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _fetchLiveGpsAndSalons();
            await _loadOffers();
            await bookingProv.fetchBookings();
          },
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Header Bar: Location Selector & Greeting
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Hello, $firstName',
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: _fetchLiveGpsAndSalons,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      _liveGpsLocation,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  if (_isFetchingGps)
                                    const SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary),
                                    )
                                  else
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 15,
                                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SVIconButton(
                        icon: Icons.notifications_none_rounded,
                        onPressed: () => context.push('/notifications'),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Integrated Search Bar (Pushes dedicated /search screen)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
                  child: SVSearchField(
                    readOnly: true,
                    hasActiveFilter: salonProv.hasActiveFilters,
                    onTap: () => context.push('/search'),
                    hintText: 'Search salons, styling, facials, nails...',
                  ),
                ),
              ),

              // 3. Active Upcoming Appointment (Prominent Card only if booking exists)
              if (nextBooking != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(60),
                          width: 1.2,
                        ),
                        boxShadow: isDark ? null : AppSpacing.softShadow(context),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withAlpha(20),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'UPCOMING',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        nextBooking.salonName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  nextBooking.serviceName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${nextBooking.date} • ${nextBooking.timeSlot}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SVButton(
                            text: 'View',
                            size: SVButtonSize.sm,
                            variant: SVButtonVariant.secondary,
                            onPressed: () => context.go('/bookings'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),



              // 5. Featured Salons Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
                  child: SVSectionHeader(
                    title: 'Featured Venues',
                    subtitle: 'Top-rated verified beauty destinations',
                    actionLabel: 'See All',
                    onAction: () => context.push('/salon-tab'),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: salonProv.isLoading && salons.isEmpty
                    ? SizedBox(
                        height: 245,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          itemCount: 3,
                          itemBuilder: (context, index) => Container(
                            width: 250,
                            margin: const EdgeInsets.only(right: 14),
                            child: const SVSkeleton(width: 250, height: 245, borderRadius: 16),
                          ),
                        ),
                      )
                    : featuredSalons.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: SVEmptyState(
                              icon: Icons.storefront_outlined,
                              title: 'No Salons in Area',
                              description: 'We could not find any salons in your current location.',
                              actionLabel: 'Refresh',
                              onAction: _fetchLiveGpsAndSalons,
                            ),
                          )
                        : SizedBox(
                            height: 245,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              itemCount: featuredSalons.length,
                              itemBuilder: (context, index) {
                                final salon = featuredSalons[index];
                                final isFav = user?.favoriteSalons.contains(salon.id) ?? false;
                                return SVSalonCard(
                                  salon: salon,
                                  isFavorite: isFav,
                                  isCompact: true,
                                  onTap: () => context.push('/salon/${salon.id}', extra: {'salon': salon}),
                                  onFavoriteToggle: () => auth.toggleFavorite(salon.id),
                                );
                              },
                            ),
                          ),
              ),

              // 6. Curated Offers Strip
              if (_featuredOffers.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 10),
                    child: SVSectionHeader(
                      title: 'Exclusive Offers',
                      subtitle: 'Save on your next beauty session',
                      actionLabel: 'All Deals',
                      onAction: () => context.push('/offers'),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      itemCount: _featuredOffers.length,
                      itemBuilder: (context, index) {
                        final offer = _featuredOffers[index];
                        return Container(
                          width: 250,
                          margin: const EdgeInsets.only(right: 12),
                          child: SVOfferCard(
                            offer: offer,
                            margin: EdgeInsets.zero,
                            onApply: () {
                              Clipboard.setData(ClipboardData(text: offer.code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Offer "${offer.code}" applied & copied!'),
                                  backgroundColor: AppColors.primary,
                                  duration: const Duration(seconds: 3),
                                  action: SnackBarAction(
                                    label: 'Book Now',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      if (offer.primarySalonId != null && offer.primarySalonId!.isNotEmpty) {
                                        context.push('/salon/${offer.primarySalonId}');
                                      } else {
                                        context.push('/salon-tab');
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              // 7. Popular Services Near You
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 10),
                  child: SVSectionHeader(
                    title: 'Trending Treatments',
                    subtitle: 'Frequently booked services in your city',
                  ),
                ),
              ),
              if (salonProv.isNearbyLoading && nearbyServices.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: List.generate(
                        3,
                        (_) => const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: SVSkeleton(width: double.infinity, height: 72, borderRadius: 14),
                        ),
                      ),
                    ),
                  ),
                )
              else if (trendingServices.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final service = trendingServices[index];
                        final salonLogoUrl = service.salonLogo.isNotEmpty
                            ? ApiConfig.resolveImageUrl(service.salonLogo)
                            : (service.salon.imageUrl.isNotEmpty
                                ? ApiConfig.resolveImageUrl(service.salon.imageUrl)
                                : '');
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
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
                                  width: 48,
                                  height: 48,
                                  child: salonLogoUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: salonLogoUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceSecondary,
                                          ),
                                          errorWidget: (context, url, err) => const SVFallbackLogo(
                                            logoSize: 24,
                                            padding: 8,
                                          ),
                                        )
                                      : const SVFallbackLogo(
                                          logoSize: 24,
                                          padding: 8,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.serviceName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${service.salonName} • ${service.durationMinutes} mins',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.formatNPR(service.price),
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SVButton(
                                    text: 'Book',
                                    size: SVButtonSize.sm,
                                    onPressed: () {
                                      final bk = context.read<BookingProvider>();
                                      bk.startBookingFlow(service.salon, service.service);
                                      context.push('/booking-flow');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: trendingServices.take(6).length,
                    ),
                  ),
                ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
