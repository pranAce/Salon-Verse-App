import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/auth/services/auth_provider.dart';
import 'package:salonverse/shared/design_system/sv_button.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _locationAddressController;
  late TextEditingController _locationCityController;
  double _lat = 27.7172;
  double _lng = 85.3240;
  bool _isFetchingGps = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name);
    _phoneController = TextEditingController(text: user?.number);
    _dobController = TextEditingController(text: user?.dateOfBirth);
    _locationAddressController = TextEditingController(
      text: user?.homeLocationAddress ?? 'Thamel, Kathmandu',
    );
    _locationCityController = TextEditingController(
      text: user?.homeLocationCity ?? 'Kathmandu',
    );
    _lat = user?.homeLocationLat ?? 27.7172;
    _lng = user?.homeLocationLng ?? 85.3240;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _locationAddressController.dispose();
    _locationCityController.dispose();
    super.dispose();
  }

  Future<void> _fetchGpsLocation() async {
    setState(() => _isFetchingGps = true);

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _lat = pos.latitude;
      _lng = pos.longitude;
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final city = p.locality ?? 'Kathmandu';
        final street = p.street ?? p.subLocality ?? 'Thamel';

        setState(() {
          _locationAddressController.text = "$street, $city";
          _locationCityController.text = city;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Detected GPS: $street, $city'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isFetchingGps = false);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      dateOfBirth: _dobController.text.trim().isEmpty ? null : _dobController.text.trim(),
      homeLocation: {
        'address': _locationAddressController.text.trim(),
        'city': _locationCityController.text.trim(),
        'latitude': _lat,
        'longitude': _lng,
      },
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account & Location saved successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to save profile.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Information',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 14),

                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1940),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      final m = picked.month.toString().padLeft(2, '0');
                      final d = picked.day.toString().padLeft(2, '0');
                      _dobController.text = "${picked.year}-$m-$d";
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _dobController,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth (Birthday Perks)',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Home Service Address',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _isFetchingGps ? null : _fetchGpsLocation,
                      icon: _isFetchingGps
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.my_location_rounded, size: 16, color: AppColors.primary),
                      label: Text(
                        'Fetch GPS',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _locationAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Street Address',
                    prefixIcon: Icon(Icons.home_work_outlined),
                  ),
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _locationCityController,
                  decoration: const InputDecoration(
                    labelText: 'City / District',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                ),
                const SizedBox(height: 32),

                SVButton(
                  text: 'Save Changes',
                  isFullWidth: true,
                  isLoading: authProvider.isLoading,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
