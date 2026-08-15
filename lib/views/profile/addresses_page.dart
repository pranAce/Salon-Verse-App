import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:salonverse/controllers/auth_provider.dart';
import 'package:salonverse/theme/app_theme.dart';
import 'package:salonverse/widgets/app_button.dart';
import 'package:salonverse/widgets/empty_state.dart';
import 'package:salonverse/widgets/feedback_helper.dart';
import 'package:salonverse/views/salon/map_location_picker.dart';

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
          address: (homeAddr != null && homeAddr.isNotEmpty)
              ? homeAddr
              : 'Thamel, Kathmandu',
          city: (homeCity != null && homeCity.isNotEmpty)
              ? homeCity
              : 'Kathmandu',
          latitude: user?.homeLocationLat ?? 27.7172,
          longitude: user?.homeLocationLng ?? 85.3240,
          isDefault: true,
        ),
        SavedAddress(
          id: 'addr_work',
          label: 'Work',
          address: 'Durbar Marg, Kathmandu',
          city: 'Kathmandu',
          latitude: 27.7115,
          longitude: 85.3180,
          isDefault: false,
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
    AppFeedback.success(context, "Default delivery address updated.");
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
    AppFeedback.info(context, "Address removed.");
  }

  void _showAddAddressDialog([SavedAddress? editAddress]) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String selectedLabel = editAddress?.label ?? 'Home';
    final addressController = TextEditingController(
      text: editAddress?.address ?? '',
    );
    final cityController = TextEditingController(
      text: editAddress?.city ?? 'Kathmandu',
    );
    double lat = editAddress?.latitude ?? 27.7172;
    double lng = editAddress?.longitude ?? 85.3240;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1C1B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    editAddress != null ? "Edit Address" : "Add New Address",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: ['Home', 'Work', 'Other'].map((label) {
                  final isSel = selectedLabel == label;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setModalState(() => selectedLabel = label);
                      },
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSel
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: "Street Address / Landmark",
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: "City",
                  prefixIcon: const Icon(Icons.location_city_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text(
                        "Pick on Map",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        final picked = await Navigator.push<PickedLocation>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MapLocationPicker(
                              initialLat: lat,
                              initialLng: lng,
                            ),
                          ),
                        );
                        if (picked != null) {
                          setModalState(() {
                            addressController.text = picked.address;
                            lat = picked.latitude;
                            lng = picked.longitude;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.my_location_rounded,
                        size: 18,
                        color: Color(0xFFEC4899),
                      ),
                      label: const Text(
                        "Use Live GPS",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEC4899),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          final pos = await Geolocator.getCurrentPosition();
                          final placemarks = await placemarkFromCoordinates(
                            pos.latitude,
                            pos.longitude,
                          );
                          if (placemarks.isNotEmpty) {
                            final p = placemarks.first;
                            setModalState(() {
                              lat = pos.latitude;
                              lng = pos.longitude;
                              addressController.text =
                                  "${p.street ?? p.subLocality ?? 'Near'}, ${p.locality ?? 'Kathmandu'}";
                              cityController.text = p.locality ?? 'Kathmandu';
                            });
                          }
                        } catch (_) {
                          if (ctx.mounted) {
                            AppFeedback.warning(
                              ctx,
                              "Could not fetch GPS. Please pick on map.",
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              AppButton(
                label: editAddress != null ? "Update Address" : "Save Address",
                onPressed: () {
                  if (addressController.text.trim().isEmpty) {
                    AppFeedback.warning(context, "Please provide an address.");
                    return;
                  }
                  final newAddr = SavedAddress(
                    id:
                        editAddress?.id ??
                        'addr_${DateTime.now().millisecondsSinceEpoch}',
                    label: selectedLabel,
                    address: addressController.text.trim(),
                    city: cityController.text.trim().isNotEmpty
                        ? cityController.text.trim()
                        : 'Kathmandu',
                    latitude: lat,
                    longitude: lng,
                    isDefault: editAddress?.isDefault ?? (_addresses.isEmpty),
                  );

                  setState(() {
                    if (editAddress != null) {
                      final idx = _addresses.indexWhere(
                        (a) => a.id == editAddress.id,
                      );
                      if (idx != -1) _addresses[idx] = newAddr;
                    } else {
                      _addresses.add(newAddr);
                    }
                  });
                  _saveAddresses();
                  Navigator.pop(ctx);
                  AppFeedback.success(context, "Address saved successfully!");
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
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "My Addresses",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_rounded),
            onPressed: () => _showAddAddressDialog(),
            tooltip: "Add Address",
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _addresses.isEmpty
            ? EmptyState(
                icon: Icons.location_off_rounded,
                title: "No saved addresses",
                subtitle:
                    "Add your home or office address for seamless Home Service booking.",
                actionLabel: "Add Address",
                onAction: () => _showAddAddressDialog(),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  final addr = _addresses[index];
                  return _buildAddressCard(theme, isDark, addr);
                },
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: AppButton(
            label: "+ Add New Address",
            onPressed: () => _showAddAddressDialog(),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(ThemeData theme, bool isDark, SavedAddress addr) {
    final IconData iconData;
    switch (addr.label.toLowerCase()) {
      case 'home':
        iconData = Icons.home_rounded;
        break;
      case 'work':
      case 'office':
        iconData = Icons.work_rounded;
        break;
      default:
        iconData = Icons.location_on_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: addr.isDefault
              ? const Color(0xFFEC4899)
              : (isDark ? const Color(0xFF2C2A29) : Colors.grey.shade200),
          width: addr.isDefault ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 0 : 5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      (addr.isDefault ? const Color(0xFFEC4899) : Colors.grey)
                          .withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  iconData,
                  color: addr.isDefault
                      ? const Color(0xFFEC4899)
                      : Colors.grey.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          addr.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        if (addr.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEC4899).withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "DEFAULT",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFEC4899),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      addr.city,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
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
                    const PopupMenuItem(
                      value: 'default',
                      child: Text("Set as Default"),
                    ),
                  const PopupMenuItem(value: 'edit', child: Text("Edit")),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text("Delete", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            addr.address,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "GPS: ${addr.latitude.toStringAsFixed(4)}, ${addr.longitude.toStringAsFixed(4)}",
                style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
              ),
              if (!addr.isDefault)
                GestureDetector(
                  onTap: () => _setDefaultAddress(addr.id),
                  child: const Text(
                    "Set Default",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEC4899),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
