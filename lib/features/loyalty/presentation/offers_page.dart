import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/loyalty/models/offer_model.dart';
import 'package:salonverse/features/home/services/app_service.dart';
import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/shared/design_system/sv_cards.dart';
import 'package:salonverse/shared/design_system/sv_selection_widgets.dart';
import 'package:salonverse/shared/design_system/sv_feedback_states.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  List<OfferModel> _offers = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Discounts',
    'Seasonal',
    'Packages',
    'Special',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOffers();
    });
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AppService.instance.getOffers();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result is Success<List<OfferModel>>) {
          _offers = result.data;
        } else if (result is Failure<List<OfferModel>>) {
          _errorMessage = result.message;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOffers = _selectedCategory == 'All'
        ? _offers
        : _offers.where((o) => o.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Special Offers',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Filter Strip
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return SVCFilterChip(
                    label: cat,
                    isSelected: isSelected,
                    onSelected: () => setState(() => _selectedCategory = cat),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Offers List
            Expanded(
              child: _isLoading
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: 3,
                      itemBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.only(bottom: 14),
                        child: SVSkeleton(width: double.infinity, height: 140, borderRadius: 20),
                      ),
                    )
                  : _errorMessage != null
                      ? SVErrorState(
                          message: _errorMessage!,
                          onRetry: _loadOffers,
                        )
                      : filteredOffers.isEmpty
                          ? const SVEmptyState(
                              icon: Icons.local_offer_outlined,
                              title: 'No Offers Available',
                              description: 'Check back later for seasonal promotions and discounts.',
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                              itemCount: filteredOffers.length,
                              itemBuilder: (context, index) {
                                final offer = filteredOffers[index];
                                return SVOfferCard(
                                  offer: offer,
                                  onApply: () {
                                    Clipboard.setData(ClipboardData(text: offer.code));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Offer "${offer.code}" applied & copied!'),
                                        backgroundColor: AppColors.primary,
                                        duration: const Duration(seconds: 3),
                                        action: SnackBarAction(
                                          label: 'Book Now',
                                          textColor: Colors.white,
                                          onPressed: () {
                                            if (offer.primarySalonId != null && offer.primarySalonId!.isNotEmpty) {
                                              context.push('/salon/${offer.primarySalonId}');
                                            } else {
                                              context.push('/salon-tab');
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
