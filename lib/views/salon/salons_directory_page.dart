import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:salonverse/controllers/auth_provider.dart';
import 'package:salonverse/controllers/salon_provider.dart';
import 'package:salonverse/models/salon_model.dart';
import 'package:salonverse/models/user_model.dart';
import 'package:salonverse/theme/app_theme.dart';
import 'package:salonverse/widgets/empty_state.dart';

class SalonsDirectoryPage extends StatefulWidget {
  const SalonsDirectoryPage({super.key});

  @override
  State<SalonsDirectoryPage> createState() => _SalonsDirectoryPageState();
}

class _SalonsDirectoryPageState extends State<SalonsDirectoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().currentUser;
    final salonProvider = context.watch<SalonProvider>();

    final list = salonProvider.salons.where((salon) {
      final query = _searchQuery.toLowerCase();
      return salon.name.toLowerCase().contains(query) ||
          salon.address.toLowerCase().contains(query) ||
          salon.city.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Explore Salons'), elevation: 0),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkSurfaceElevated
                      : AppColors.lightSurfaceSecondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "Search by name or location...",
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            Expanded(
              child: list.isEmpty
                  ? EmptyState(
                      icon: Icons.storefront_rounded,
                      title: 'No salons found',
                      subtitle: 'Try adjusting your search criteria.',
                      actionLabel: 'Clear Search',
                      onAction: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = "";
                        });
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final salon = list[index];
                        return _buildTile(context, user, salon);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, UserModel? user, SalonModel salon) {
    final theme = Theme.of(context);
    final isFav = user?.favoriteSalons.contains(salon.id) ?? false;

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
                        child: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFav ? Colors.red : theme.colorScheme.primary,
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
