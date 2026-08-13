import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Result returned when user confirms location on the map picker.
class PickedLocation {
  final double latitude;
  final double longitude;
  final String address;

  PickedLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

/// Uber/Pathao-style full-screen map location picker.
/// Fixed center pin — user drags the map underneath.
class MapLocationPicker extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapLocationPicker({super.key, this.initialLat, this.initialLng});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  late LatLng _currentCenter;
  String _addressText = "Move the map to set location";
  String _subAddressText = "";
  bool _isGeocoding = false;
  bool _isLocating = false;
  bool _isDragging = false;

  late AnimationController _pinController;
  late Animation<double> _pinAnimation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentCenter = LatLng(
      widget.initialLat ?? 27.7172,
      widget.initialLng ?? 85.3240,
    );

    _pinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pinAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pinController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reverseGeocode(_currentCenter);
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(LatLng latlng) async {
    setState(() => _isGeocoding = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latlng.latitude,
        latlng.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        final subLocality = place.subLocality ?? place.street ?? place.name ?? '';
        final locality = place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            '';
        final country = place.country ?? '';

        String main = '';
        String sub = '';
        if (subLocality.isNotEmpty && !subLocality.contains('+')) {
          main = subLocality;
          sub = '$locality, $country';
        } else if (locality.isNotEmpty) {
          main = locality;
          sub = country;
        } else {
          main = '${latlng.latitude.toStringAsFixed(4)}, ${latlng.longitude.toStringAsFixed(4)}';
          sub = '';
        }

        setState(() {
          _addressText = main;
          _subAddressText = sub;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _addressText = '${latlng.latitude.toStringAsFixed(4)}, ${latlng.longitude.toStringAsFixed(4)}';
          _subAddressText = '';
        });
      }
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please enable GPS location services'),
              backgroundColor: const Color(0xFFEC4899),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final newCenter = LatLng(position.latitude, position.longitude);
      _mapController.move(newCenter, 16.0);
      setState(() => _currentCenter = newCenter);
      _reverseGeocode(newCenter);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to get current location'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const pink = Color(0xFFEC4899);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0E0D) : Colors.white,
      body: Stack(
        children: [
          // ═══════════════════════════════════════════
          // MAP
          // ═══════════════════════════════════════════
          Positioned.fill(
            bottom: 200 + bottomPad, // Leave room for bottom panel
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: 15.5,
                minZoom: 4,
                maxZoom: 18,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onPositionChanged: (pos, hasGesture) {
                  if (hasGesture) {
                    if (!_isDragging) {
                      setState(() => _isDragging = true);
                      _pinController.forward();
                    }
                    _currentCenter = pos.center;
                  }
                },
                onMapEvent: (event) {
                  if (event is MapEventMoveEnd || event is MapEventFlingAnimationEnd) {
                    if (_isDragging) {
                      _pinController.reverse();
                      setState(() => _isDragging = false);
                      _reverseGeocode(_currentCenter);
                    }
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: isDark
                      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: isDark ? const ['a', 'b', 'c', 'd'] : const [],
                  userAgentPackageName: 'com.salonverse.com',
                ),
              ],
            ),
          ),

          // ═══════════════════════════════════════════
          // FIXED CENTER PIN
          // ═══════════════════════════════════════════
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 200 + bottomPad,
            child: IgnorePointer(
              child: Center(
                child: AnimatedBuilder(
                  animation: _pinAnimation,
                  builder: (context, child) {
                    final lift = _pinAnimation.value * 14;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 40 + lift),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Pin head
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: _isDragging ? 52 : 48,
                            height: _isDragging ? 52 : 48,
                            decoration: BoxDecoration(
                              color: pink,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: pink.withAlpha(_isDragging ? 100 : 60),
                                  blurRadius: _isDragging ? 24 : 12,
                                  spreadRadius: _isDragging ? 4 : 1,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 24),
                          ),
                          // Pin stem
                          Container(
                            width: 3,
                            height: 14,
                            decoration: BoxDecoration(
                              color: pink,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          // Ground shadow
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: _isDragging ? 20 : 12,
                            height: _isDragging ? 6 : 4,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(_isDragging ? 30 : 50),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // ═══════════════════════════════════════════
          // TOP BAR — Back button + Title
          // ═══════════════════════════════════════════
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (isDark ? Colors.black : Colors.white).withAlpha(230),
                    (isDark ? Colors.black : Colors.white).withAlpha(0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 20, color: isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Set Delivery Location',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1F2333),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ═══════════════════════════════════════════
          // GPS FAB
          // ═══════════════════════════════════════════
          Positioned(
            right: 16,
            bottom: 210 + bottomPad,
            child: GestureDetector(
              onTap: _isLocating ? null : _goToCurrentLocation,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _isLocating
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: pink,
                          ),
                        ),
                      )
                    : const Icon(Icons.my_location_rounded, color: pink, size: 22),
              ),
            ),
          ),

          // ═══════════════════════════════════════════
          // BOTTOM CONFIRM PANEL
          // ═══════════════════════════════════════════
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad + 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1816) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(70),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Address row
                  Row(
                    children: [
                      // Location icon container
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: pink.withAlpha(15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.location_on_rounded, color: pink, size: 22),
                      ),
                      const SizedBox(width: 14),
                      // Address text
                      Expanded(
                        child: _isGeocoding
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 140,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withAlpha(40),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: 90,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withAlpha(25),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _addressText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : const Color(0xFF1F2333),
                                    ),
                                  ),
                                  if (_subAddressText.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      _subAddressText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                      // Refresh button
                      GestureDetector(
                        onTap: () => _reverseGeocode(_currentCenter),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: pink.withAlpha(12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.refresh_rounded, color: pink, size: 18),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Coordinates chip
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withAlpha(6) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.withAlpha(30)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.gps_fixed_rounded, size: 13, color: Colors.grey.shade500),
                        const SizedBox(width: 8),
                        Text(
                          '${_currentCenter.latitude.toStringAsFixed(6)},  ${_currentCenter.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                            color: Colors.grey.shade500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: pink.withAlpha(100),
                      ),
                      onPressed: _isGeocoding
                          ? null
                          : () {
                              final fullAddr = _subAddressText.isNotEmpty
                                  ? '$_addressText, $_subAddressText'
                                  : _addressText;
                              Navigator.pop(
                                context,
                                PickedLocation(
                                  latitude: _currentCenter.latitude,
                                  longitude: _currentCenter.longitude,
                                  address: fullAddr,
                                ),
                              );
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _isGeocoding ? 'Locating...' : 'Confirm Location',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
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
        ],
      ),
    );
  }
}
