import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:salonverse/features/auth/services/auth_provider.dart';
import 'package:salonverse/features/salons/services/salon_provider.dart';
import 'package:salonverse/features/booking/services/booking_provider.dart';
import 'package:salonverse/features/home/services/settings_provider.dart';
import 'package:salonverse/shared/widgets/nearby_service_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String _liveGpsLocation = 'Locating...';
  bool _isFetchingGps = false;
  bool _locationPromptActive = false;
  double? _userLat;
  double? _userLng;
  late TextEditingController _searchController;

  final List<String> _categories = const [
    'All',
    'Hair',
    'Beard',
    'Facial',
    'Massage',
    'Nails',
    'Makeup',
    'Bridal',
    'Spa',
  ];

  final List<Map<String, String>> _sortOptions = const [
    {'key': 'recommended', 'label': 'Recommended'},
    {'key': 'lowest_price', 'label': 'Lowest Price'},
    {'key': 'nearest', 'label': 'Nearest'},
    {'key': 'highest_rated', 'label': 'Highest Rated'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLiveGpsAndSalons();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationOnResume();
    }
  }

  Future<void> _checkLocationOnResume() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();
      if (serviceEnabled &&
          permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        if (_locationPromptActive && mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          _locationPromptActive = false;
        }
        _fetchLiveGpsAndSalons();
      }
    } catch (_) {}
  }

  Future<void> _fetchLiveGpsAndSalons() async {
    if (_isFetchingGps) return;
    setState(() {
      _isFetchingGps = true;
      _liveGpsLocation = 'Fetching GPS...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _liveGpsLocation = 'Enable Location';
          });
          _promptForcedLocation(
            title: "Location Services Disabled",
            message:
                "Location is required to discover local salons near you. Please turn on device location.",
            isServiceDisabled: true,
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _liveGpsLocation = 'Location Denied';
            });
            _promptForcedLocation(
              title: "Location Permission Required",
              message:
                  "SalonVerse requires your device location to show nearby salons. Please grant permission to continue.",
              isServiceDisabled: false,
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _liveGpsLocation = 'Permission Denied';
          });
          _promptForcedLocation(
            title: "Location Permission Blocked",
            message:
                "Location permission is permanently denied. Please enable location permission in app settings to use SalonVerse.",
            isServiceDisabled: false,
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _userLat = position.latitude;
      _userLng = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final locality = place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            'Kathmandu';
        final subLocality = place.subLocality ?? place.street ?? place.name ?? '';
        final formattedLocation = subLocality.isNotEmpty && !subLocality.contains('+')
            ? "$subLocality, $locality"
            : "$locality, Nepal";

        if (mounted) {
          setState(() {
            _liveGpsLocation = formattedLocation;
          });
        }
      }

      if (mounted) {
        final salonProv = context.read<SalonProvider>();
        salonProv.fetchSalons(lat: _userLat, lng: _userLng, forceRefresh: true);
        salonProv.fetchNearbyServices(lat: _userLat, lng: _userLng);
      }
    } catch (e) {
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
      if (mounted) {
        setState(() {
          _isFetchingGps = false;
        });
      }
    }
  }

  void _promptForcedLocation({
    required String title,
    required String message,
    required bool isServiceDisabled,
  }) {
    if (_locationPromptActive) return;
    _locationPromptActive = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.location_off_rounded,
              color: Color(0xFFEC4899),
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2333),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF4B5563),
            height: 1.4,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC4899),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              _locationPromptActive = false;
              if (isServiceDisabled) {
                await Geolocator.openLocationSettings();
              } else {
                await Geolocator.openAppSettings();
              }
            },
            child: Text(
              isServiceDisabled
                  ? 'Turn On Location Services'
                  : 'Open Location Settings',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final salonProv = context.watch<SalonProvider>();
    final user = auth.currentUser;
    final userName = user != null && user.name.trim().isNotEmpty
        ? user.name.trim().split(' ').first
        : 'Guest';
    final isSearching = salonProv.searchQuery.isNotEmpty;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1F2333);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0C0C) : const Color(0xFFFFF6F8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchLiveGpsAndSalons,
          color: const Color(0xFFEC4899),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Welcome & Location Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8B8FA3),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: primaryTextColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('✨', style: TextStyle(fontSize: 20)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: _fetchLiveGpsAndSalons,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 15,
                                  color: Color(0xFFEC4899),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    _liveGpsLocation,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF8B8FA3),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (_isFetchingGps) ...[
                                  const SizedBox(width: 6),
                                  const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Color(0xFFEC4899),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    Stack(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(isDark ? 0 : 5),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.notifications_none_rounded,
                              color: primaryTextColor,
                              size: 22,
                            ),
                            onPressed: () => context.push('/notifications'),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 12,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEC4899),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Upcoming Appointment Card (Requirement 15)
                Builder(
                  builder: (context) {
                    final bookingProv = context.watch<BookingProvider>();
                    final upcomingList = bookingProv.bookings.where((b) {
                      final st = b.status.toLowerCase();
                      return st != 'completed' && st != 'cancelled' && st != 'no_show';
                    }).toList();

                    if (upcomingList.isEmpty) return const SizedBox.shrink();
                    final upcoming = upcomingList.first;

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEC4899).withAlpha(40),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.event_available_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'UPCOMING APPOINTMENT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white70,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${upcoming.serviceName} • ${upcoming.salonName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${upcoming.date} at ${upcoming.timeSlot}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFEC4899),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              context.read<SettingsProvider>().setPage(1);
                              context.go('/bookings');
                            },
                            child: const Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Prominent Marketplace Search Input
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 0 : 4),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (q) => salonProv.updateSearchQuery(
                      q,
                      lat: _userLat,
                      lng: _userLng,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search services or salons (e.g. Haircut, Facial)...',
                      hintStyle: const TextStyle(
                        color: Color(0xFFA5A9B8),
                        fontSize: 13,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 14, right: 8),
                        child: Icon(
                          Icons.search_rounded,
                          color: Color(0xFFEC4899),
                          size: 22,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 40),
                      suffixIcon: isSearching
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Color(0xFF8B8FA3),
                                size: 18,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                salonProv.clearSearch();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Horizontal Service Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSel = salonProv.selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSel,
                          showCheckmark: false,
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                              color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                          backgroundColor: isDark ? const Color(0xFF1E1C1B) : Colors.white,
                          selectedColor: const Color(0xFFEC4899),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          elevation: isSel ? 2 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSel
                                  ? const Color(0xFFEC4899)
                                  : (isDark ? const Color(0xFF2E2B29) : Colors.grey.shade200),
                            ),
                          ),
                          onSelected: (_) {
                            salonProv.selectCategory(cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Services Near You Header & Sort Options Dropdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSearching
                                ? 'Search Results (${salonProv.nearbyServices.length})'
                                : 'Services Near You',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Compare prices & book from nearby salons',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Sort Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2E2B29) : Colors.grey.shade300,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: salonProv.selectedSort,
                          isDense: true,
                          icon: const Icon(Icons.sort_rounded, size: 16, color: Color(0xFFEC4899)),
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: primaryTextColor),
                          dropdownColor: isDark ? const Color(0xFF1E1C1B) : Colors.white,
                          onChanged: (val) {
                            if (val != null) salonProv.setSortOption(val);
                          },
                          items: _sortOptions.map((opt) {
                            return DropdownMenuItem(
                              value: opt['key'],
                              child: Text(opt['label']!),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Nearby Services Marketplace List
                if (salonProv.isNearbyLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: Color(0xFFEC4899)),
                    ),
                  )
                else if (salonProv.nearbyServices.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF181716) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'No services found nearby',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Try searching for another service like "Haircut" or "Facial", or select a category above.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12.5),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      for (final item in salonProv.nearbyServices) ...[
                        NearbyServiceCard(
                          item: item,
                          onViewSalon: () {
                            context.push('/salon/${item.salonId}', extra: {'salon': item.salon});
                          },
                          onBookNow: () {
                            final bookingProvider = context.read<BookingProvider>();
                            bookingProvider.startBookingFlow(item.salon, item.service);
                            context.push('/booking-flow');
                          },
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
