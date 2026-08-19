import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/salons/models/salon_model.dart';
import 'package:salonverse/features/booking/services/booking_provider.dart';
import 'package:salonverse/features/auth/services/auth_provider.dart';
import 'package:salonverse/core/widgets/sv_cards.dart';
import 'package:salonverse/core/widgets/sv_selection_widgets.dart';
import 'package:salonverse/core/widgets/sv_feedback_states.dart';
import 'package:salonverse/core/widgets/sv_button.dart';

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
  String _selectedCategory = 'All';
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  bool _isFetchingGps = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      final bookingProv = context.read<BookingProvider>();
      if (user?.number != null && user!.number!.isNotEmpty) {
        _contactController.text = user.number!;
        bookingProv.setContactNumber(user.number!);
      }
      if (bookingProv.homeAddress.isNotEmpty) {
        _addressController.text = bookingProv.homeAddress;
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _fetchHomeGps() async {
    if (_isFetchingGps) return;
    setState(() => _isFetchingGps = true);

    try {
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
        final subLocality = place.subLocality ?? place.street ?? '';
        final locality = place.locality ?? 'Kathmandu';
        final address = subLocality.isNotEmpty
            ? "$subLocality, $locality"
            : locality;

        if (mounted) {
          _addressController.text = address;
          final prov = context.read<BookingProvider>();
          prov.setHomeAddress(address);
          prov.setHomeCoordinates(position.latitude, position.longitude);
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isFetchingGps = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<BookingProvider>();

    final categories = [
      'All',
      ...widget.salon.services.map((s) => s.category).toSet(),
    ];

    final filteredServices = _selectedCategory == 'All'
        ? widget.salon.services
        : widget.salon.services
              .where((s) => s.category == _selectedCategory)
              .toList();

    final selectedService = provider.selectedService;
    final sourceStylists = provider.stylists.isNotEmpty
        ? provider.stylists
        : widget.salon.stylists;

    List<StylistModel> matchingStylists = sourceStylists;
    if (selectedService != null) {
      final catLower = selectedService.category.toLowerCase().trim();
      final nameLower = selectedService.name.toLowerCase().trim();
      final filtered = sourceStylists.where((st) {
        if (st.specialties.isEmpty) return true;
        return st.specialties.any((spec) {
          final s = spec.toLowerCase();
          return s.contains(catLower) ||
              catLower.contains(s) ||
              s.contains(nameLower) ||
              nameLower.contains(s);
        });
      }).toList();
      if (filtered.isNotEmpty) {
        matchingStylists = filtered;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              boxShadow: isDark ? null : AppSpacing.softShadow(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryTint,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              provider.isHomeService
                                  ? Icons.home_repair_service_rounded
                                  : Icons.storefront_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.isHomeService
                                      ? 'Home Service Delivery'
                                      : 'In-Salon Appointment',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                Text(
                                  provider.isHomeService
                                      ? 'Specialist comes to your doorstep'
                                      : 'Visit the salon venue directly',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: isDark
                                        ? AppColors.darkTextTertiary
                                        : AppColors.lightTextTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch.adaptive(
                      value: provider.isHomeService,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        provider.setHomeService(val);
                      },
                    ),
                  ],
                ),

                if (provider.isHomeService) ...[
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _addressController,
                          onChanged: (val) => provider.setHomeAddress(val),
                          decoration: const InputDecoration(
                            labelText: 'Your Full Street Address',
                            prefixIcon: Icon(Icons.home_outlined, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SVIconButton(
                        icon: Icons.my_location_rounded,
                        onPressed: _fetchHomeGps,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
                    onChanged: (val) => provider.setContactNumber(val),
                    decoration: const InputDecoration(
                      labelText: 'Contact Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          SVSectionHeader(
            title: 'Select Specialist',
            subtitle: selectedService != null
                ? 'Specialists qualified for ${selectedService.name}'
                : 'Choose a dedicated stylist or any available',
          ),
          const SizedBox(height: 8),
          provider.isLoadingStylists
              ? const SizedBox(
                  height: 144,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : SizedBox(
                  height: 144,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: matchingStylists.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isAnySel = provider.selectedStylist == null;
                        return GestureDetector(
                          onTap: () => provider.selectStylist(null),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 110,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isAnySel
                                  ? (isDark
                                        ? AppColors.primaryTintDark
                                        : AppColors.primaryTint)
                                  : (isDark
                                        ? AppColors.darkSurface
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.cardRadius,
                              ),
                              border: Border.all(
                                color: isAnySel
                                    ? AppColors.primary
                                    : (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder),
                                width: isAnySel ? 1.5 : 1.0,
                              ),
                              boxShadow: isDark
                                  ? null
                                  : AppSpacing.softShadow(context),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: isAnySel
                                      ? AppColors.primary
                                      : (isDark
                                            ? AppColors.darkSurfaceElevated
                                            : AppColors.primaryTint),
                                  child: Icon(
                                    Icons.groups_rounded,
                                    size: 22,
                                    color: isAnySel
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Any Specialist',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Auto-assigned',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    color: isDark
                                        ? AppColors.darkTextTertiary
                                        : AppColors.lightTextTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final stylist = matchingStylists[index - 1];
                      final isSel = provider.selectedStylist?.id == stylist.id;
                      return SVStylistCard(
                        stylist: stylist,
                        isSelected: isSel,
                        onTap: () => provider.selectStylist(stylist),
                      );
                    },
                  ),
                ),
          const SizedBox(height: 20),

          SVSectionHeader(
            title: 'Choose Service',
            subtitle: 'Select the treatment for your appointment',
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
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
          const SizedBox(height: 12),

          if (filteredServices.isEmpty)
            const SVEmptyState(
              icon: Icons.content_cut_rounded,
              title: 'No Services',
              description: 'No services found in this category.',
            )
          else
            ...filteredServices.map((service) {
              final isSel = provider.selectedService?.id == service.id;
              return SVServiceCard(
                service: service,
                isSelected: isSel,
                onTap: () => provider.selectService(service),
              );
            }),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
