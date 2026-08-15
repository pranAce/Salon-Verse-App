import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:salonverse/models/salon_model.dart';
import 'package:salonverse/controllers/booking_provider.dart';
import 'package:salonverse/controllers/auth_provider.dart';
import 'package:salonverse/views/salon/map_location_picker.dart';

class BookingStep1Services extends StatefulWidget {
  final SalonModel salon;
  final ServiceModel? selectedService;
  final StylistModel? selectedStylist;

  const BookingStep1Services({
    super.key,
    required this.salon,
    required this.selectedService,
    required this.selectedStylist,
  });

  @override
  State<BookingStep1Services> createState() => _BookingStep1ServicesState();
}

class _BookingStep1ServicesState extends State<BookingStep1Services> {
  bool _isFetchingGps = false;
  String _gpsLocationText = "";
  final TextEditingController _contactPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user?.number != null && user!.number!.isNotEmpty) {
        _contactPhoneController.text = user.number!;
        context.read<BookingProvider>().setContactNumber(user.number!);
      }
    });
  }

  @override
  void dispose() {
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchHomeGpsLocation() async {
    if (_isFetchingGps) return;
    setState(() {
      _isFetchingGps = true;
      _gpsLocationText = "Fetching live GPS location...";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _gpsLocationText = "GPS location disabled on device.";
          });
          _showLocationPermissionDialog(
            title: "Location Services Disabled",
            message:
                "Turn on GPS to set your home delivery address accurately.",
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
              _gpsLocationText = "Location permission denied.";
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _gpsLocationText = "Location permission permanently denied.";
          });
          _showLocationPermissionDialog(
            title: "Location Permission Required",
            message:
                "SalonVerse needs location permission to locate your home address for staff delivery. Please enable it in Settings.",
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

        final fullDisplayAddress =
            "$formattedLocation (Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)})";

        if (mounted) {
          setState(() {
            _gpsLocationText = fullDisplayAddress;
          });
          context.read<BookingProvider>().setHomeAddress(formattedLocation);
          context.read<BookingProvider>().setHomeCoordinates(
            position.latitude,
            position.longitude,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final user = context.read<AuthProvider>().currentUser;
        final fallback = user?.homeLocationAddress?.isNotEmpty == true
            ? user!.homeLocationAddress!
            : "Kathmandu, Nepal";
        setState(() {
          _gpsLocationText = fallback;
        });
        context.read<BookingProvider>().setHomeAddress(fallback);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingGps = false;
        });
      }
    }
  }

  void _showLocationPermissionDialog({
    required String title,
    required String message,
    required bool isServiceDisabled,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: Color(0xFFEC4899),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
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
              if (isServiceDisabled) {
                await Geolocator.openLocationSettings();
              } else {
                await Geolocator.openAppSettings();
              }
            },
            child: Text(isServiceDisabled ? 'Turn On GPS' : 'Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _openMapPicker(
    BuildContext context,
    BookingProvider provider,
  ) async {
    final result = await Navigator.push<PickedLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => MapLocationPicker(
          initialLat: provider.homeLat,
          initialLng: provider.homeLng,
        ),
      ),
    );

    if (result != null && mounted) {
      provider.setHomeAddress(result.address);
      provider.setHomeCoordinates(result.latitude, result.longitude);
      setState(() {
        _gpsLocationText =
            "${result.address} (${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)})";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<BookingProvider>();

    if (widget.selectedService == null && widget.salon.services.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.selectService(widget.salon.services.first);
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.room_service_outlined,
                color: Color(0xFFEC4899),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "Service Location",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    provider.setHomeService(false);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: !provider.isHomeService
                          ? const Color(0xFFEC4899).withAlpha(12)
                          : (isDark
                                ? const Color(0xFF1E1C1B)
                                : Colors.grey.shade50),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: !provider.isHomeService
                            ? const Color(0xFFEC4899)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.storefront_rounded,
                          color: !provider.isHomeService
                              ? const Color(0xFFEC4899)
                              : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "In-Salon",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: !provider.isHomeService
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: !provider.isHomeService
                                ? const Color(0xFFEC4899)
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    provider.setHomeService(true);
                    if (provider.homeAddress.isEmpty) {
                      _fetchHomeGpsLocation();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: provider.isHomeService
                          ? const Color(0xFFEC4899).withAlpha(12)
                          : (isDark
                                ? const Color(0xFF1E1C1B)
                                : Colors.grey.shade50),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: provider.isHomeService
                            ? const Color(0xFFEC4899)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.home_rounded,
                          color: provider.isHomeService
                              ? const Color(0xFFEC4899)
                              : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Home Service 🏠",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: provider.isHomeService
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: provider.isHomeService
                                ? const Color(0xFFEC4899)
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (provider.isHomeService) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1C1B)
                    : Colors.pink.shade50.withAlpha(80),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFEC4899).withAlpha(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.my_location_rounded,
                        color: Color(0xFFEC4899),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "Service Location",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _openMapPicker(context, provider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEC4899).withAlpha(15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFEC4899).withAlpha(30),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.map_rounded,
                                size: 14,
                                color: Color(0xFFEC4899),
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Pick on Map",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFEC4899),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFEC4899).withAlpha(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFFEC4899),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _gpsLocationText.isNotEmpty
                                    ? _gpsLocationText
                                    : (provider.homeAddress.isNotEmpty
                                          ? provider.homeAddress
                                          : "Tap 'Refresh GPS' to detect coordinates"),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        GestureDetector(
                          onTap: () => _openMapPicker(context, provider),
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFEC4899).withAlpha(30),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Stack(
                                children: [
                                  IgnorePointer(
                                    child: FlutterMap(
                                      options: MapOptions(
                                        initialCenter: LatLng(
                                          provider.homeLat ?? 27.7172,
                                          provider.homeLng ?? 85.3240,
                                        ),
                                        initialZoom: 15.0,
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate: isDark
                                              ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                                              : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          subdomains: isDark
                                              ? const ['a', 'b', 'c', 'd']
                                              : const [],
                                          userAgentPackageName:
                                              'com.salonverse.com',
                                        ),
                                        MarkerLayer(
                                          markers: [
                                            Marker(
                                              point: LatLng(
                                                provider.homeLat ?? 27.7172,
                                                provider.homeLng ?? 85.3240,
                                              ),
                                              width: 40,
                                              height: 40,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFEC4899,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFFEC4899,
                                                      ).withAlpha(100),
                                                      blurRadius: 10,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.home_work_rounded,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (isDark
                                                    ? Colors.black
                                                    : Colors.white)
                                                .withAlpha(210),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.touch_app_rounded,
                                            size: 14,
                                            color: Color(0xFFEC4899),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              provider.homeLat != null
                                                  ? "${provider.homeLat!.toStringAsFixed(4)}, ${provider.homeLng!.toStringAsFixed(4)}  •  Tap to change"
                                                  : "Tap to select location on map",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Contact Phone Number",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _contactPhoneController,
                    keyboardType: TextInputType.phone,
                    onChanged: (val) => provider.setContactNumber(val),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Enter contact number for Home Service...",
                      prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: isDark ? Colors.black26 : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withAlpha(40),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          Row(
            children: [
              const Icon(
                Icons.style_outlined,
                color: Color(0xFFEC4899),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "Choose Service",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (widget.salon.services.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "No services available.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...widget.salon.services.map((svc) {
              final isSel = widget.selectedService?.id == svc.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSel
                      ? const Color(0xFFEC4899).withAlpha(8)
                      : (isDark
                            ? const Color(0xFF1E1C1B)
                            : Colors.grey.shade50),
                  borderRadius: BorderRadius.circular(20),
                  border: isSel
                      ? Border.all(color: const Color(0xFFEC4899), width: 1.5)
                      : null,
                  boxShadow: isSel
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 0 : 3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: InkWell(
                  onTap: () {
                    provider.selectService(svc);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isSel
                              ? const Color(0xFFEC4899).withAlpha(25)
                              : (isDark
                                    ? const Color(0xFF2C2A29)
                                    : Colors.grey.shade200),
                          child: Icon(
                            Icons.spa_rounded,
                            color: isSel
                                ? const Color(0xFFEC4899)
                                : (isDark
                                      ? Colors.white60
                                      : Colors.grey.shade600),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                svc.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      svc.category.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "•  ${svc.durationMinutes} min session",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Rs. ${svc.price.round()}",
                              style: TextStyle(
                                color: isSel
                                    ? const Color(0xFFEC4899)
                                    : (isDark
                                          ? Colors.white
                                          : const Color(0xFF111827)),
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              isSel
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_off_rounded,
                              color: isSel
                                  ? const Color(0xFFEC4899)
                                  : (isDark
                                        ? Colors.white30
                                        : Colors.grey.shade400),
                              size: 22,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

          const SizedBox(height: 32),

          Row(
            children: [
              const Icon(
                Icons.face_retouching_natural_outlined,
                color: Color(0xFFEC4899),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "Choose Stylist",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Builder(
            builder: (context) {
              final Map<String, StylistModel> uniqueStylists = {};
              for (var s in widget.salon.stylists) {
                if (!uniqueStylists.containsKey(s.id) &&
                    !uniqueStylists.values.any((item) => item.name == s.name)) {
                  uniqueStylists[s.id] = s;
                }
              }
              List<StylistModel> list = uniqueStylists.values.toList();

              if (list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "No specific stylists registered for this salon yet.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              }

              if (widget.selectedStylist == null && list.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  provider.selectStylist(list.first);
                });
              }

              return SizedBox(
                height: 148,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: list.length,
                  itemBuilder: (context, idx) {
                    final stylist = list[idx];
                    final isSel = widget.selectedStylist?.id == stylist.id;

                    return GestureDetector(
                      onTap: () {
                        provider.selectStylist(stylist);
                      },
                      child: Container(
                        width: 114,
                        margin: const EdgeInsets.only(
                          right: 12,
                          bottom: 8,
                          top: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSel
                              ? const Color(0xFFEC4899).withAlpha(8)
                              : (isDark
                                    ? const Color(0xFF1E1C1B)
                                    : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: isSel
                              ? Border.all(
                                  color: const Color(0xFFEC4899),
                                  width: 1.5,
                                )
                              : null,
                          boxShadow: isSel
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(
                                      isDark ? 0 : 3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                        ),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: double.infinity),
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage: stylist.imageUrl.isNotEmpty
                                      ? NetworkImage(stylist.imageUrl)
                                      : null,
                                  child: stylist.imageUrl.isEmpty
                                      ? const Icon(Icons.person, size: 28)
                                      : null,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  stylist.name.isNotEmpty
                                      ? stylist.name.split(' ')[0]
                                      : 'Stylist',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${stylist.rating}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (isSel)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFEC4899),
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
