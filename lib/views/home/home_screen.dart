import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../controllers/auth_provider.dart';
import '../../controllers/salon_provider.dart';
import '../../models/salon_model.dart';

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

  final List<Map<String, dynamic>> _categories = const [
    {
      'title': 'Hair',
      'icon': Icons.content_cut_rounded,
      'bg': Color(0xFFFCE7F3),
      'color': Color(0xFFEC4899),
    },
    {
      'title': 'Spa',
      'icon': Icons.spa_outlined,
      'bg': Color(0xFFD1FAE5),
      'color': Color(0xFF059669),
    },
    {
      'title': 'Makeup',
      'icon': Icons.brush_outlined,
      'bg': Color(0xFFFFEDD5),
      'color': Color(0xFFEA580C),
    },
    {
      'title': 'Nails',
      'icon': Icons.style_outlined,
      'bg': Color(0xFFF3E8FF),
      'color': Color(0xFF9333EA),
    },
    {
      'title': 'Skin',
      'icon': Icons.face_outlined,
      'bg': Color(0xFFDBEAFE),
      'color': Color(0xFF2563EB),
    },
    {
      'title': 'Others',
      'icon': Icons.more_horiz_rounded,
      'bg': Color(0xFFF3F4F6),
      'color': Color(0xFF4B5563),
    },
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
        final locality =
            place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            'Kathmandu';
        final subLocality =
            place.subLocality ?? place.street ?? place.name ?? '';

        final formattedLocation =
            subLocality.isNotEmpty && !subLocality.contains('+')
            ? "$subLocality, $locality"
            : "$locality, ${place.country ?? 'Nepal'}";

        if (mounted) {
          setState(() {
            _liveGpsLocation = formattedLocation;
          });
        }
      }

      if (mounted) {
        context.read<SalonProvider>().fetchSalons(
          lat: _userLat,
          lng: _userLng,
          forceRefresh: true,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _liveGpsLocation = 'Kathmandu, Nepal';
          _userLat = 27.7172;
          _userLng = 85.3240;
        });
        context.read<SalonProvider>().fetchSalons(
          lat: 27.7172,
          lng: 85.3240,
          forceRefresh: true,
        );
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
    ).then((_) {
      _locationPromptActive = false;
    });
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

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchLiveGpsAndSalons,
          color: const Color(0xFFEC4899),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Good morning',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8B8FA3),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F2333),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('👋', style: TextStyle(fontSize: 22)),
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
                              Text(
                                _liveGpsLocation,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8B8FA3),
                                  fontWeight: FontWeight.w600,
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

                    Stack(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: Color(0xFF1F2333),
                              size: 24,
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

                const SizedBox(height: 20),

                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
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
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1F2333),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search salons, services, stylists...',
                      hintStyle: const TextStyle(
                        color: Color(0xFFA5A9B8),
                        fontSize: 14,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 16, right: 10),
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
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (isSearching) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Search Results (${salonProv.salons.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2333),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          salonProv.clearSearch();
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFEC4899),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (salonProv.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                          color: Color(0xFFEC4899),
                        ),
                      ),
                    )
                  else if (salonProv.salons.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: Color(0xFFD1D5DB),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No salons found matching "${salonProv.searchQuery}"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: salonProv.salons.length,
                      itemBuilder: (context, index) {
                        final salon = salonProv.salons[index];
                        final distText = salon.distanceKm != null
                            ? '${salon.distanceKm!.toStringAsFixed(1)} km away'
                            : salon.city;

                        return _buildSalonCard(salon, distText);
                      },
                    ),
                  const SizedBox(height: 24),
                ] else ...[
                  GestureDetector(
                    onTap: () => context.push('/profile/offers'),
                    child: Container(
                      width: double.infinity,
                      height: 185,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFB7185),
                            Color(0xFFEC4899),
                            Color(0xFFF472B6),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFEC4899,
                            ).withValues(alpha: 0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 170,
                            top: 32,
                            child: Icon(
                              Icons.auto_awesome,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 15,
                            ),
                          ),
                          Positioned(
                            left: 190,
                            top: 20,
                            child: Icon(
                              Icons.auto_awesome,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 10,
                            ),
                          ),

                          Positioned(
                            left: 150,
                            bottom: 20,
                            child: Icon(
                              Icons.eco_outlined,
                              color: Colors.white.withValues(alpha: 0.35),
                              size: 36,
                            ),
                          ),

                          Positioned(
                            right: -30,
                            top: 0,
                            bottom: 0,
                            width: 160,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(24),
                              ),
                              child: ShaderMask(
                                shaderCallback: (rect) {
                                  return const LinearGradient(
                                    colors: [Colors.transparent, Colors.black],
                                    stops: [0.0, 0.28],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ).createShader(rect);
                                },
                                blendMode: BlendMode.dstIn,
                                child: Image.asset(
                                  'assets/images/model.png',
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topRight,
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Text(
                                    'LIMITED OFFER',
                                    style: TextStyle(
                                      color: Color(0xFFEC4899),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),

                                const Text(
                                  'Glow Friday',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),

                                const Text(
                                  'Up to 30% off premium\nsalons this weekend',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    height: 1.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                GestureDetector(
                                  onTap: () => context.push('/profile/offers'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Explore Offers',
                                          style: TextStyle(
                                            color: Color(0xFFEC4899),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          size: 16,
                                          color: Color(0xFFEC4899),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2333),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          salonProv.selectCategory('All');
                          context.go('/salon-tab');
                        },
                        child: const Text(
                          'View all',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEC4899),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.25,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      return GestureDetector(
                        onTap: () {
                          salonProv.selectCategory(cat['title'] as String);
                          context.go('/salon-tab');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: cat['bg'] as Color,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  cat['icon'] as IconData,
                                  color: cat['color'] as Color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cat['title'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2333),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nearby Salons',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2333),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/salon-tab'),
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEC4899),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  if (salonProv.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                          color: Color(0xFFEC4899),
                        ),
                      ),
                    )
                  else if (salonProv.salons.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            size: 40,
                            color: Color(0xFF9CA3AF),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No nearby salons found.',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: salonProv.salons.length > 5
                          ? 5
                          : salonProv.salons.length,
                      itemBuilder: (context, index) {
                        final salon = salonProv.salons[index];
                        final distText = salon.distanceKm != null
                            ? '${salon.distanceKm!.toStringAsFixed(1)} km'
                            : salon.city;

                        return _buildSalonCard(salon, distText);
                      },
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSalonCard(SalonModel salon, String distText) {
    return GestureDetector(
      onTap: () => context.push('/salon/${salon.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: salon.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        salon.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.storefront,
                              color: Color(0xFFEC4899),
                              size: 32,
                            ),
                      ),
                    )
                  : const Icon(
                      Icons.storefront,
                      color: Color(0xFFEC4899),
                      size: 32,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salon.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2333),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '📍 ${salon.address} • $distText',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8B8FA3),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFEC4899),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        salon.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        salon.priceRange,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8B8FA3),
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
    );
  }
}
