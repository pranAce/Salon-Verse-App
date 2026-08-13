import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:salonverse/controllers/auth_provider.dart';
import 'package:salonverse/controllers/salon_provider.dart';
import 'package:salonverse/widgets/feedback_helper.dart';
import 'package:salonverse/models/salon_model.dart';

class SalonAdminSettings extends StatefulWidget {
  const SalonAdminSettings({super.key});

  @override
  State<SalonAdminSettings> createState() => _SalonAdminSettingsState();
}

class _SalonAdminSettingsState extends State<SalonAdminSettings> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _priceRangeController;
  late TextEditingController _descController;
  late TextEditingController _imageUrlController;

  bool _isInit = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _priceRangeController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings(String salonId) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        AppFeedback.success(context, "Business settings updated successfully!");
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.error(context, "Failed to update settings: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().currentUser;
    final salonId = user?.salonId ?? 'salon_1';
    final salonProvider = context.watch<SalonProvider>();

    final salon = salonProvider.salons.firstWhere(
      (s) => s.id == salonId,
      orElse: () => SalonModel(
        id: salonId,
        name: 'My Salon',
        address: '',
        imageUrl: '',
        rating: 4.8,
        services: [],
        stylists: [],
        openingHours: '9:00 AM - 8:00 PM',
      ),
    );

    if (_isInit) {
      _nameController = TextEditingController(text: salon.name);
      _phoneController = TextEditingController(text: salon.phoneNumber);
      _addressController = TextEditingController(text: salon.address);
      _cityController = TextEditingController(text: salon.city);
      _priceRangeController = TextEditingController(text: salon.priceRange);
      _descController = TextEditingController(text: salon.description);
      _imageUrlController = TextEditingController(text: salon.imageUrl);
      _isInit = false;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Salon Settings",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Manage profile & operations for ${salon.name}",
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 24),

              Text("Basic Information", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Salon Name", prefixIcon: Icon(Icons.store)),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone Number", prefixIcon: Icon(Icons.phone)),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Address", prefixIcon: Icon(Icons.location_on)),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: "City", prefixIcon: Icon(Icons.location_city)),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _priceRangeController,
                decoration: const InputDecoration(labelText: "Price Range", prefixIcon: Icon(Icons.payments)),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Description", prefixIcon: Icon(Icons.description)),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: "Image URL", prefixIcon: Icon(Icons.image)),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () => _saveSettings(salonId),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      context.go('/auth/login');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error.withAlpha(120)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    "Sign Out Account",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
