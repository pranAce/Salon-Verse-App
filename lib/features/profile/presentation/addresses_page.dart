import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/features/auth/services/auth_provider.dart';
import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/shared/design_system/sv_button.dart';
import 'package:salonverse/shared/design_system/sv_feedback_states.dart';
import 'package:salonverse/shared/design_system/sv_selection_widgets.dart';

class SavedAddress {
  final String id;
  final String label;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final bool isDefault;

  SavedAddress({
    required this.id,
    required this.label,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'address': address,
    'city': city,
    'latitude': latitude,
    'longitude': longitude,
    'isDefault': isDefault,
  };

  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
    id: json['id'] ?? '',
    label: json['label'] ?? 'Home',
    address: json['address'] ?? '',
    city: json['city'] ?? 'Kathmandu',
    latitude: (json['latitude'] as num?)?.toDouble() ?? 27.7172,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 85.3240,
    isDefault: json['isDefault'] ?? false,
  );
}

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  List<SavedAddress> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final user = mounted ? context.read<AuthProvider>().currentUser : null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('saved_user_addresses');

    if (raw != null && raw.isNotEmpty) {
      try {
        final List list = json.decode(raw);
        _addresses = list
            .map((e) => SavedAddress.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {}
    }

    if (_addresses.isEmpty) {
      final homeAddr = user?.homeLocationAddress;
      final homeCity = user?.homeLocationCity;

      _addresses = [
        SavedAddress(
          id: 'addr_home',
          label: 'Home',
          address: (homeAddr != null && homeAddr.isNotEmpty) ? homeAddr : 'Thamel, Kathmandu',
          city: (homeCity != null && homeCity.isNotEmpty) ? homeCity : 'Kathmandu',
          latitude: user?.homeLocationLat ?? 27.7172,
          longitude: user?.homeLocationLng ?? 85.3240,
          isDefault: true,
        ),
      ];
      await _saveAddresses();
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(_addresses.map((a) => a.toJson()).toList());
    await prefs.setString('saved_user_addresses', data);
  }

  void _setDefaultAddress(String id) {
    setState(() {
      _addresses = _addresses.map((a) {
        return SavedAddress(
          id: a.id,
          label: a.label,
          address: a.address,
          city: a.city,
          latitude: a.latitude,
          longitude: a.longitude,
          isDefault: a.id == id,
        );
      }).toList();
    });
    _saveAddresses();
  }

  void _deleteAddress(String id) {
    setState(() {
      _addresses.removeWhere((a) => a.id == id);
      if (_addresses.isNotEmpty && !_addresses.any((a) => a.isDefault)) {
        _addresses[0] = SavedAddress(
          id: _addresses[0].id,
          label: _addresses[0].label,
          address: _addresses[0].address,
          city: _addresses[0].city,
          latitude: _addresses[0].latitude,
          longitude: _addresses[0].longitude,
          isDefault: true,
        );
      }
    });
    _saveAddresses();
  }

  void _showAddAddressDialog([SavedAddress? editAddress]) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String selectedLabel = editAddress?.label ?? 'Home';
    final addressController = TextEditingController(text: editAddress?.address ?? '');
    final cityController = TextEditingController(text: editAddress?.city ?? 'Kathmandu');
    double lat = editAddress?.latitude ?? 27.7172;
    double lng = editAddress?.longitude ?? 85.3240;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.sheetRadius)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                editAddress != null ? 'Edit Address' : 'Add New Address',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: ['Home', 'Work', 'Other'].map((label) {
                  final isSel = selectedLabel == label;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SVCFilterChip(
                      label: label,
                      isSelected: isSel,
                      onSelected: () => setModalState(() => selectedLabel = label),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Street Address / Area',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
              ),
              const SizedBox(height: 24),

              SVButton(
                text: editAddress != null ? 'Update Address' : 'Save Address',
                isFullWidth: true,
                onPressed: () {
                  if (addressController.text.trim().isEmpty) return;
                  final newAddr = SavedAddress(
                    id: editAddress?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
                    label: selectedLabel,
                    address: addressController.text.trim(),
                    city: cityController.text.trim().isNotEmpty ? cityController.text.trim() : 'Kathmandu',
                    latitude: lat,
                    longitude: lng,
                    isDefault: editAddress?.isDefault ?? (_addresses.isEmpty),
                  );

                  setState(() {
                    if (editAddress != null) {
                      final idx = _addresses.indexWhere((a) => a.id == editAddress.id);
                      if (idx != -1) _addresses[idx] = newAddr;
                    } else {
                      _addresses.add(newAddr);
                    }
                  });
                  _saveAddresses();
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Addresses',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_rounded),
            onPressed: () => _showAddAddressDialog(),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _addresses.isEmpty
                ? SVEmptyState(
                    icon: Icons.location_off_rounded,
                    title: 'No Saved Addresses',
                    description: 'Add your home or office address for seamless doorstep delivery.',
                    actionLabel: 'Add Address',
                    onAction: () => _showAddAddressDialog(),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      final addr = _addresses[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: addr.isDefault
                                ? AppColors.primary
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: addr.isDefault ? 1.5 : 1,
                          ),
                          boxShadow: isDark ? null : AppSpacing.softShadow(context),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTint,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                addr.label.toLowerCase() == 'home'
                                    ? Icons.home_rounded
                                    : (addr.label.toLowerCase() == 'work'
                                        ? Icons.work_rounded
                                        : Icons.location_on_rounded),
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        addr.label,
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                      if (addr.isDefault) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withAlpha(20),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'DEFAULT',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${addr.address}, ${addr.city}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'default') _setDefaultAddress(addr.id);
                                if (val == 'edit') _showAddAddressDialog(addr);
                                if (val == 'delete') _deleteAddress(addr.id);
                              },
                              itemBuilder: (ctx) => [
                                if (!addr.isDefault)
                                  const PopupMenuItem(value: 'default', child: Text('Set Default')),
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: SVButton(
            text: '+ Add New Address',
            isFullWidth: true,
            onPressed: () => _showAddAddressDialog(),
          ),
        ),
      ),
    );
  }
}
