import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:salonverse/views/salon/map_location_picker.dart';

import 'package:salonverse/models/salon_model.dart';
import 'package:salonverse/controllers/booking_provider.dart';
import 'package:salonverse/controllers/auth_provider.dart';
import 'package:salonverse/theme/app_theme.dart';
import 'package:salonverse/widgets/feedback_helper.dart';

class BookingFlowPage extends StatefulWidget {
  const BookingFlowPage({super.key});

  @override
  State<BookingFlowPage> createState() => _BookingFlowPageState();
}

class _BookingFlowPageState extends State<BookingFlowPage> {
  int _currentStep = 0; // 0: Services & Stylist, 1: Schedule & Payment
  bool _isFetchingGps = false;
  String _gpsLocationText = "";
  final TextEditingController _contactPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchBookings();
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
            message: "Turn on GPS to set your home delivery address accurately.",
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
            message: "SalonVerse needs location permission to locate your home address for staff delivery. Please enable it in Settings.",
            isServiceDisabled: false,
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final locality = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? 'Kathmandu';
        final subLocality = place.subLocality ?? place.street ?? place.name ?? '';
        
        final formattedLocation = subLocality.isNotEmpty && !subLocality.contains('+')
            ? "$subLocality, $locality"
            : "$locality, ${place.country ?? 'Nepal'}";

        final fullDisplayAddress = "$formattedLocation (Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)})";

        if (mounted) {
          setState(() {
            _gpsLocationText = fullDisplayAddress;
          });
          context.read<BookingProvider>().setHomeAddress(formattedLocation);
          context.read<BookingProvider>().setHomeCoordinates(position.latitude, position.longitude);
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
            const Icon(Icons.location_on_rounded, color: Color(0xFFEC4899), size: 24),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Future<void> _openMapPicker(BuildContext context, BookingProvider provider) async {
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
        _gpsLocationText = "${result.address} (${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)})";
      });
    }
  }

  List<String> _getDynamicTimeSlots(SalonModel salon, ServiceModel? service, DateTime? activeDate) {
    return salon.publishedTimeSlots;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookingProvider = context.watch<BookingProvider>();

    if (bookingProvider.selectedSalon == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Book Appointment'),
          elevation: 0,
        ),
        body: const Center(child: Text('No active booking details found.')),
      );
    }

    final salon = bookingProvider.selectedSalon!;
    final selectedService = bookingProvider.selectedService;
    final selectedStylist = bookingProvider.selectedStylist;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090808) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF090808) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : Colors.black),
          onPressed: () {
            if (_currentStep == 1) {
              setState(() {
                _currentStep = 0;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              salon.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            Text(
              _currentStep == 0 ? "Select Service & Stylist" : "Select Schedule & Payment",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper progress indicator
            _buildStepperProgress(isDark),
            
            // Step contents
            Expanded(
              child: _currentStep == 0
                  ? _buildStep1Contents(theme, isDark, salon, selectedService, selectedStylist, bookingProvider)
                  : _buildStep2Contents(theme, isDark, salon, selectedService, selectedStylist, bookingProvider),
            ),
            
            // Bottom Action Bar
            _buildBottomActionBar(theme, isDark, selectedService, selectedStylist, bookingProvider),
          ],
        ),
      ),
    );
  }

  // ─── Stepper Progress Header ───
  Widget _buildStepperProgress(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090808) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1E1C1B) : Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _stepNode(0, "Services", _currentStep >= 0, isDark),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: _currentStep >= 1 ? const Color(0xFFEC4899) : (isDark ? const Color(0xFF2C2A29) : Colors.grey.shade200),
            ),
          ),
          _stepNode(1, "Schedule", _currentStep >= 1, isDark),
        ],
      ),
    );
  }

  Widget _stepNode(int index, String label, bool isActive, bool isDark) {
    final activeColor = const Color(0xFFEC4899);
    final inactiveColor = isDark ? const Color(0xFF2C2A29) : Colors.grey.shade200;
    
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            "${index + 1}",
            style: TextStyle(
              color: isActive ? Colors.white : (isDark ? Colors.white38 : Colors.grey),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.white38 : Colors.grey),
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─── Step 1 Contents: Select Service & Stylist ───
  Widget _buildStep1Contents(
    ThemeData theme,
    bool isDark,
    SalonModel salon,
    ServiceModel? selectedService,
    StylistModel? selectedStylist,
    BookingProvider provider,
  ) {
    try {
      if (selectedService == null && salon.services.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.selectService(salon.services.first);
        });
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Location Mode Header
            Row(
              children: [
                const Icon(Icons.room_service_outlined, color: Color(0xFFEC4899), size: 18),
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

            // In-Salon vs Home Service Selector Cards
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      provider.setHomeService(false);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        color: !provider.isHomeService
                            ? const Color(0xFFEC4899).withAlpha(12)
                            : (isDark ? const Color(0xFF1E1C1B) : Colors.grey.shade50),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: !provider.isHomeService ? const Color(0xFFEC4899) : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.storefront_rounded,
                            color: !provider.isHomeService ? const Color(0xFFEC4899) : Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "In-Salon",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: !provider.isHomeService ? FontWeight.bold : FontWeight.w600,
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
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        color: provider.isHomeService
                            ? const Color(0xFFEC4899).withAlpha(12)
                            : (isDark ? const Color(0xFF1E1C1B) : Colors.grey.shade50),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: provider.isHomeService ? const Color(0xFFEC4899) : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.home_rounded,
                            color: provider.isHomeService ? const Color(0xFFEC4899) : Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Home Service 🏠",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: provider.isHomeService ? FontWeight.bold : FontWeight.w600,
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

            // Home Service GPS & Phone details card (Only visible if Home Service selected)
            if (provider.isHomeService) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1C1B) : Colors.pink.shade50.withAlpha(80),
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
                        const Icon(Icons.my_location_rounded, color: Color(0xFFEC4899), size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          "Service Location",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => _openMapPicker(context, provider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEC4899).withAlpha(15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFEC4899).withAlpha(30)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.map_rounded, size: 14, color: Color(0xFFEC4899)),
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
                        border: Border.all(color: const Color(0xFFEC4899).withAlpha(40)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, color: Color(0xFFEC4899), size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _gpsLocationText.isNotEmpty ? _gpsLocationText : (provider.homeAddress.isNotEmpty ? provider.homeAddress : "Tap 'Refresh GPS' to detect coordinates"),
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

                          // Interactive Map Preview (tap to open full picker)
                          GestureDetector(
                            onTap: () => _openMapPicker(context, provider),
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFEC4899).withAlpha(30)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Stack(
                                  children: [
                                    // Real map tile preview
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
                                            subdomains: isDark ? const ['a', 'b', 'c', 'd'] : const [],
                                            userAgentPackageName: 'com.salonverse.com',
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
                                                    color: const Color(0xFFEC4899),
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: const Color(0xFFEC4899).withAlpha(100),
                                                        blurRadius: 10,
                                                        spreadRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 18),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Tap overlay
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: (isDark ? Colors.black : Colors.white).withAlpha(210),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.touch_app_rounded, size: 14, color: Color(0xFFEC4899)),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                provider.homeLat != null
                                                    ? "${provider.homeLat!.toStringAsFixed(4)}, ${provider.homeLng!.toStringAsFixed(4)}  •  Tap to change"
                                                    : "Tap to select location on map",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? Colors.white : Colors.black87,
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? Colors.black26 : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.withAlpha(40)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Choose Service Header
            Row(
              children: [
                const Icon(Icons.style_outlined, color: Color(0xFFEC4899), size: 18),
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

            // Services custom list
            if (salon.services.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("No services available.", style: TextStyle(color: Colors.grey)),
              )
            else
              ...salon.services.map((svc) {
                final isSel = selectedService?.id == svc.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSel
                        ? const Color(0xFFEC4899).withAlpha(8)
                        : (isDark ? const Color(0xFF1E1C1B) : Colors.grey.shade50),
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
                                ? const Color(0xFFEC4899).withAlpha(20)
                                : (isDark ? const Color(0xFF2C2A29) : Colors.grey.shade200),
                            child: Icon(
                              Icons.spa_outlined,
                              color: isSel ? const Color(0xFFEC4899) : Colors.grey,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  svc.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${svc.durationMinutes} min session",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                                  color: isSel ? const Color(0xFFEC4899) : (isDark ? Colors.white70 : Colors.black87),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                isSel ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                                color: isSel ? const Color(0xFFEC4899) : Colors.grey.shade400,
                                size: 20,
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

            // Choose Stylist Header
            Row(
              children: [
                const Icon(Icons.face_retouching_natural_outlined, color: Color(0xFFEC4899), size: 18),
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

            // Stylists horizontal list
            Builder(
              builder: (context) {
                final Map<String, StylistModel> uniqueStylists = {};
                for (var s in salon.stylists) {
                  if (!uniqueStylists.containsKey(s.id) && !uniqueStylists.values.any((item) => item.name == s.name)) {
                    uniqueStylists[s.id] = s;
                  }
                }
                List<StylistModel> list = uniqueStylists.values.toList();

                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text("No specific stylists registered for this salon yet.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                  );
                }

                if (selectedStylist == null && list.isNotEmpty) {
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
                      final isSel = selectedStylist?.id == stylist.id;
                      
                      return GestureDetector(
                        onTap: () {
                          provider.selectStylist(stylist);
                        },
                        child: Container(
                          width: 114,
                          margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
                          decoration: BoxDecoration(
                            color: isSel
                                ? const Color(0xFFEC4899).withAlpha(8)
                                : (isDark ? const Color(0xFF1E1C1B) : Colors.white),
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
                                    stylist.name.isNotEmpty ? stylist.name.split(' ')[0] : 'Stylist',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${stylist.rating}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                      Text(
                                        ' (${(stylist.rating * 12).toInt()})',
                                        style: const TextStyle(color: Colors.grey, fontSize: 9),
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
                                    child: const Icon(Icons.check, color: Colors.white, size: 10),
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
    } catch (e, stack) {
      debugPrint("Exception inside _buildStep1Contents: $e\n$stack");
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                "Error rendering services list: $e",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
  }

  // ─── Step 2 Contents: Select Schedule & Payment ───
  Widget _buildStep2Contents(
    ThemeData theme,
    bool isDark,
    SalonModel salon,
    ServiceModel? service,
    StylistModel? stylist,
    BookingProvider provider,
  ) {
    final activeDate = provider.selectedDate;
    final activeTime = provider.selectedTime;

    // Dynamic Dates: 10 days starting today
    final dates = List.generate(10, (idx) => DateTime.now().add(Duration(days: idx)));

    // Dynamic Time Slots derived from operating hours & service duration (e.g. 30 mins)
    final dynamicTimeSlots = _getDynamicTimeSlots(salon, service, activeDate);

    // List of time slots already booked by any user for this salon & selected date
    final dateStr = activeDate != null
        ? "${activeDate.year}-${activeDate.month.toString().padLeft(2, '0')}-${activeDate.day.toString().padLeft(2, '0')}"
        : "";

    final bookedTimeSlots = provider.bookings
        .where((b) => b.salonId == salon.id && b.date == dateStr && b.status != 'cancelled')
        .map((b) => b.timeSlot)
        .toSet();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select Date Title
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: Color(0xFFEC4899), size: 18),
              const SizedBox(width: 8),
              Text(
                "Select Date",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dynamic Calendar Row
          SizedBox(
            height: 74,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, idx) {
                final d = dates[idx];
                final isSel = activeDate != null &&
                    activeDate.year == d.year &&
                    activeDate.month == d.month &&
                    activeDate.day == d.day;
                
                final weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                final weekdayStr = weekdays[d.weekday - 1];

                return GestureDetector(
                  onTap: () {
                    provider.selectDate(d);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 58,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFEC4899) : (isDark ? const Color(0xFF1E1C1B) : Colors.grey.shade50),
                      borderRadius: BorderRadius.circular(16),
                      border: isSel
                          ? null
                          : Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 20 : 40)),
                      boxShadow: isSel
                          ? [
                              BoxShadow(
                                color: const Color(0xFFEC4899).withAlpha(40),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekdayStr,
                          style: TextStyle(
                            color: isSel ? Colors.white : (isDark ? Colors.white38 : Colors.grey),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d.day.toString(),
                          style: TextStyle(
                            color: isSel ? Colors.white : (isDark ? Colors.white : Colors.black),
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

          const SizedBox(height: 32),

          // Available slots header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.alarm_on_rounded, color: Color(0xFFEC4899), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "Available Slots",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Text(
                "${dynamicTimeSlots.where((s) => !bookedTimeSlots.contains(s)).length} Open",
                style: const TextStyle(fontSize: 11, color: Color(0xFFEC4899), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Grid View slots with Occupied / Booked Slot Filtering
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.1,
            ),
            itemCount: dynamicTimeSlots.length,
            itemBuilder: (context, idx) {
              final slot = dynamicTimeSlots[idx];
              final isSel = activeTime == slot;
              final isBooked = bookedTimeSlots.contains(slot);

              return InkWell(
                onTap: isBooked
                    ? null
                    : () {
                        provider.selectTime(slot);
                      },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isBooked
                        ? (isDark ? const Color(0xFF161514) : Colors.grey.shade200)
                        : isSel
                            ? const Color(0xFFEC4899)
                            : (isDark ? const Color(0xFF1E1C1B) : Colors.grey.shade50),
                    borderRadius: BorderRadius.circular(12),
                    border: isSel
                        ? null
                        : Border.all(
                            color: isBooked
                                ? Colors.red.withAlpha(40)
                                : theme.colorScheme.outline.withAlpha(isDark ? 20 : 40),
                          ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        slot,
                        style: TextStyle(
                          color: isBooked
                              ? Colors.grey
                              : isSel
                                  ? Colors.white
                                  : (isDark ? Colors.white : Colors.black87),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          decoration: isBooked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (isBooked) ...[
                        const SizedBox(height: 2),
                        const Text(
                          "BOOKED",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w900,
                            fontSize: 8,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Payment Selection
          Row(
            children: [
              const Icon(Icons.payment_outlined, color: Color(0xFFEC4899), size: 18),
              const SizedBox(width: 8),
              Text(
                "Payment Method",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Payment Cards
          ...['Cash', 'eSewa', 'Khalti'].map((method) {
            final isSel = provider.paymentMethod == method;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSel
                    ? const Color(0xFFEC4899).withAlpha(8)
                    : (isDark ? const Color(0xFF1E1C1B) : Colors.white),
                borderRadius: BorderRadius.circular(14),
                border: isSel
                    ? Border.all(color: const Color(0xFFEC4899), width: 1.5)
                    : null,
                boxShadow: isSel
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 0 : 3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: InkWell(
                onTap: () => provider.selectPaymentMethod(method),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        method == 'Cash'
                            ? Icons.payments_outlined
                            : Icons.account_balance_wallet_outlined,
                        color: isSel ? const Color(0xFFEC4899) : Colors.grey,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          method == 'Cash' ? 'Pay at Salon' : '$method Wallet',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Icon(
                        isSel ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: isSel ? const Color(0xFFEC4899) : Colors.grey,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Sticky Bottom Action Bar ───
  Widget _buildBottomActionBar(
    ThemeData theme,
    bool isDark,
    ServiceModel? selectedService,
    StylistModel? selectedStylist,
    BookingProvider provider,
  ) {
    if (selectedService == null) {
      return const SizedBox.shrink();
    }

    final isStep1 = _currentStep == 0;
    final stylistName = selectedStylist?.name.split(' ')[0] ?? 'Assigned Staff';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161514) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E1C1B) : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brief descriptions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedService.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  "Stylist: $stylistName • Rs. ${selectedService.price.round()}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Stepper primary action button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 52),
              backgroundColor: const Color(0xFFEC4899),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: provider.isLoading
                ? null
                : () async {
                    if (isStep1) {
                      setState(() {
                        _currentStep = 1;
                      });
                    } else {
                      // Validate Step 2 inputs
                      if (provider.selectedTime == null) {
                        AppFeedback.warning(context, "Please pick an appointment time slot.");
                        return;
                      }

                      final router = GoRouter.of(context);
                      final successBooking = await provider.confirmBooking();
                      if (!mounted) return;
                      if (successBooking != null) {
                        router.replace('/payment-confirmation');
                      } else {
                        AppFeedback.error(context, provider.error ?? "Failed to book slot.");
                      }
                    }
                  },
            child: provider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    isStep1 ? "Continue" : "Book Appointment",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
          ),
        ],
      ),
    );
  }
}

