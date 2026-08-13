import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:salonverse/controllers/auth_provider.dart';
import 'package:salonverse/widgets/app_button.dart';
import 'package:salonverse/widgets/app_text_field.dart';
import 'package:salonverse/widgets/feedback_helper.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationAddressController;
  late TextEditingController _locationCityController;
  bool _isFetchingGps = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name);
    _phoneController = TextEditingController(text: user?.number);
    _locationAddressController = TextEditingController(text: user?.homeLocationAddress ?? 'Thamel, Kathmandu');
    _locationCityController = TextEditingController(text: user?.homeLocationCity ?? 'Kathmandu');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationAddressController.dispose();
    _locationCityController.dispose();
    super.dispose();
  }

  Future<void> _fetchGpsLocation() async {
    setState(() {
      _isFetchingGps = true;
    });

    try {
      final res = await http.get(Uri.parse('http://ip-api.com/json')).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final city = data['city'] ?? 'Kathmandu';
        final region = data['regionName'] ?? 'Bagmati';
        final country = data['country'] ?? 'Nepal';

        setState(() {
          _locationAddressController.text = "$city, $region";
          _locationCityController.text = city;
        });

        if (mounted) {
          AppFeedback.success(context, "Detected Live Location: $city, $country");
        }
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.info(context, "Set to default Kathmandu location.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingGps = false;
        });
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      homeLocation: {
        'address': _locationAddressController.text.trim(),
        'city': _locationCityController.text.trim(),
        'latitude': 27.7172,
        'longitude': 85.3240,
      },
    );

    if (mounted) {
      if (success) {
        AppFeedback.success(context, "Account & Home Location saved to server!");
        Navigator.pop(context);
      } else {
        AppFeedback.error(context, authProvider.error ?? "Failed to save profile changes.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Account & Home Location'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Name
                AppTextField(
                  controller: _nameController,
                  label: "Full Name",
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Please enter your name.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone
                AppTextField(
                  controller: _phoneController,
                  label: "Phone Number",
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Home Location",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    TextButton.icon(
                      onPressed: _isFetchingGps ? null : _fetchGpsLocation,
                      icon: _isFetchingGps
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.my_location_rounded, size: 16, color: Color(0xFFE91E63)),
                      label: const Text("Fetch Live GPS", style: TextStyle(color: Color(0xFFE91E63), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Home Location Address
                AppTextField(
                  controller: _locationAddressController,
                  label: "Street Address Location",
                  prefixIcon: Icons.home_work_outlined,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // City
                AppTextField(
                  controller: _locationCityController,
                  label: "City / District",
                  prefixIcon: Icons.location_city_outlined,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 32),

                // Action Button
                AppButton(
                  label: "Save Home Location",
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
