import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/features/auth/services/auth_provider.dart';
import 'package:salonverse/features/salons/services/salon_provider.dart';
import 'package:salonverse/shared/design_system/sv_cards.dart';
import 'package:salonverse/shared/design_system/sv_feedback_states.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final salonProvider = context.watch<SalonProvider>();

    final favsList = salonProvider.getFavoriteSalons(
      user?.favoriteSalons ?? [],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Salons',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: favsList.isEmpty
            ? SVEmptyState(
                icon: Icons.favorite_border_rounded,
                title: 'No Saved Salons',
                description: 'Bookmark your favorite beauty spots to quickly access and book them anytime.',
                actionLabel: 'Explore Salons',
                onAction: () => context.go('/salon-tab'),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: favsList.length,
                itemBuilder: (context, index) {
                  final salon = favsList[index];
                  return SVSalonCard(
                    salon: salon,
                    isFavorite: true,
                    onTap: () => context.push('/salon/${salon.id}', extra: {'salon': salon}),
                    onFavoriteToggle: () => auth.toggleFavorite(salon.id),
                  );
                },
              ),
      ),
    );
  }
}
