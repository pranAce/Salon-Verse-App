import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:salonverse/controllers/auth_provider.dart';
import 'package:salonverse/controllers/salon_provider.dart';
import 'package:salonverse/models/salon_model.dart';
import 'package:salonverse/theme/app_theme.dart';
import 'package:salonverse/widgets/empty_state.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final salonProvider = context.watch<SalonProvider>();

    final favsList = salonProvider.getFavoriteSalons(
      user?.favoriteSalons ?? [],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Salons')),
      body: SafeArea(
        child: favsList.isEmpty
            ? EmptyState(
                icon: Icons.favorite_border_rounded,
                title: 'No saved salons',
                subtitle:
                    'Bookmark your favorite beauty spots to access them quickly.',
                actionLabel: 'Explore Salons',
                onAction: () => context.go('/home'),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                itemCount: favsList.length,
                itemBuilder: (context, index) {
                  final salon = favsList[index];
                  return _buildTile(context, salon);
                },
              ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, SalonModel salon) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        context.push('/salon/${salon.id}', extra: {'salon': salon});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          border: theme.cardTheme.shape is RoundedRectangleBorder
              ? Border.fromBorderSide(
                  (theme.cardTheme.shape as RoundedRectangleBorder).side,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppSpacing.cardShadow(context),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: salon.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  color: theme.colorScheme.surfaceContainer,
                ),
                errorWidget: (context, url, err) => Container(
                  width: 80,
                  height: 80,
                  color: theme.colorScheme.surfaceContainer,
                  child: const Icon(
                    Icons.storefront_rounded,
                    size: 24,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          salon.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<AuthProvider>().toggleFavorite(salon.id);
                        },
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    salon.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            salon.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        salon.priceRange,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
