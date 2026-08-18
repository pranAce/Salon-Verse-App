import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/auth/services/auth_provider.dart';
import 'package:salonverse/features/salons/services/salon_provider.dart';
import 'package:salonverse/shared/design_system/sv_cards.dart';
import 'package:salonverse/shared/design_system/sv_selection_widgets.dart';
import 'package:salonverse/shared/design_system/sv_feedback_states.dart';
import 'package:salonverse/features/home/presentation/search_filter_sheet.dart';

class SalonsDirectoryPage extends StatefulWidget {
  const SalonsDirectoryPage({super.key});

  @override
  State<SalonsDirectoryPage> createState() => _SalonsDirectoryPageState();
}

class _SalonsDirectoryPageState extends State<SalonsDirectoryPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final salonProv = context.read<SalonProvider>();
      if (salonProv.salons.isEmpty) {
        salonProv.fetchSalons();
      }
      if (salonProv.searchQuery.isNotEmpty) {
        _searchController.text = salonProv.searchQuery;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SearchFilterSheet(),
    );
  }

  String _formatSortName(String sort) {
    switch (sort) {
      case 'rating':
        return 'Top Rated';
      case 'nearest':
        return 'Nearest';
      case 'price_asc':
        return 'Best Price';
      default:
        return 'Recommended';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final salonProv = context.watch<SalonProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    final list = salonProv.filteredSalons;
    final hasActiveFilter = salonProv.hasActiveFilters;

    if (_searchController.text != salonProv.searchQuery) {
      _searchController.text = salonProv.searchQuery;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        titleSpacing: 18,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Explore Salons',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${list.length} ${list.length == 1 ? 'Venue' : 'Venues'}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Text(
              salonProv.selectedCategory != 'All'
                  ? 'Showing ${salonProv.selectedCategory} specialty salons'
                  : 'Discover top-rated beauty artists near you',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              size: 22,
            ),
            tooltip: _isGridView ? 'List View' : 'Grid View',
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _isGridView = !_isGridView);
            },
          ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.tune_rounded,
                  color: hasActiveFilter ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  size: 22,
                ),
                if (hasActiveFilter)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Filter Salons',
            onPressed: _openFilterSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => salonProv.fetchSalons(forceRefresh: true),
          color: AppColors.primary,
          child: Column(
            children: [
              // 1. Hero Search Input (Tap launches dedicated /search)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
                child: SVSearchField(
                  controller: _searchController,
                  hintText: 'Search salon, service, or location...',
                  hasActiveFilter: hasActiveFilter,
                  onTap: () => context.push('/search'),
                  onChanged: (val) => salonProv.updateSearchQuery(val),
                  onClear: () {
                    _searchController.clear();
                    salonProv.clearSearch();
                  },
                ),
              ),

              // 2. Active Removable Filter Chips Bar (Shown ONLY when filters are active)
              if (hasActiveFilter) _buildActiveFiltersBar(salonProv, isDark),

              // 3. Salons List / Grid View Content
              Expanded(
                child: salonProv.isLoading && list.isEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        itemCount: 4,
                        itemBuilder: (context, _) => SVSkeleton.salonCardSkeleton(context),
                      )
                    : salonProv.error != null && list.isEmpty
                        ? SVErrorState(
                            title: 'Failed to Load Salons',
                            message: salonProv.error!,
                            onRetry: () => salonProv.fetchSalons(forceRefresh: true),
                          )
                        : list.isEmpty
                            ? SVEmptyState(
                                icon: Icons.storefront_outlined,
                                title: 'No Salons Found',
                                description:
                                    'No venues match your current criteria. Try adjusting your search query or removing active filters.',
                                actionLabel: 'Reset All Filters',
                                onAction: () {
                                  _searchController.clear();
                                  salonProv.clearAllFilters();
                                },
                              )
                            : _isGridView
                                ? GridView.builder(
                                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 80),
                                    physics: const BouncingScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.72,
                                    ),
                                    itemCount: list.length,
                                    itemBuilder: (context, index) {
                                      final salon = list[index];
                                      final isFav = user?.favoriteSalons.contains(salon.id) ?? false;
                                      return SVSalonCard(
                                        salon: salon,
                                        isFavorite: isFav,
                                        isCompact: true,
                                        onTap: () => context.push('/salon/${salon.id}', extra: {'salon': salon}),
                                        onFavoriteToggle: () {
                                          auth.toggleFavorite(salon.id);
                                        },
                                      );
                                    },
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 80),
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: list.length,
                                    itemBuilder: (context, index) {
                                      final salon = list[index];
                                      final isFav = user?.favoriteSalons.contains(salon.id) ?? false;
                                      return SVSalonCard(
                                        salon: salon,
                                        isFavorite: isFav,
                                        onTap: () => context.push('/salon/${salon.id}', extra: {'salon': salon}),
                                        onFavoriteToggle: () {
                                          auth.toggleFavorite(salon.id);
                                          final isNowFav = !(user?.favoriteSalons.contains(salon.id) ?? false);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                isNowFav
                                                    ? 'Added ${salon.name} to favorites ❤️'
                                                    : 'Removed ${salon.name} from favorites',
                                              ),
                                              duration: const Duration(seconds: 2),
                                              backgroundColor: AppColors.primary,
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
      ),
    );
  }

  Widget _buildActiveFiltersBar(SalonProvider prov, bool isDark) {
    final chips = <Widget>[];

    if (prov.selectedCategory != 'All' && prov.selectedCategory.isNotEmpty) {
      chips.add(_buildRemovableChip(
        label: prov.selectedCategory,
        icon: Icons.category_rounded,
        onRemove: () => prov.selectCategory('All'),
        isDark: isDark,
      ));
    }

    if (prov.searchQuery.isNotEmpty) {
      chips.add(_buildRemovableChip(
        label: '"${prov.searchQuery}"',
        icon: Icons.search_rounded,
        onRemove: () {
          _searchController.clear();
          prov.clearSearch();
        },
        isDark: isDark,
      ));
    }

    if (prov.minRating > 0.0) {
      chips.add(_buildRemovableChip(
        label: '${prov.minRating}+ ★',
        icon: Icons.star_rounded,
        onRemove: () => prov.applyFilters(minRating: 0.0),
        isDark: isDark,
      ));
    }

    if (prov.homeServiceOnly) {
      chips.add(_buildRemovableChip(
        label: 'Home Service',
        icon: Icons.home_work_rounded,
        onRemove: () => prov.applyFilters(homeServiceOnly: false),
        isDark: isDark,
      ));
    }

    if (prov.selectedSort != 'recommended') {
      chips.add(_buildRemovableChip(
        label: _formatSortName(prov.selectedSort),
        icon: Icons.sort_rounded,
        onRemove: () => prov.setSortOption('recommended'),
        isDark: isDark,
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        children: [
          ...chips,
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _searchController.clear();
              prov.clearAllFilters();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              alignment: Alignment.center,
              child: Text(
                'Reset All',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemovableChip({
    required String label,
    required IconData icon,
    required VoidCallback onRemove,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF361421) : AppColors.primaryTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onRemove();
            },
            child: const Padding(
              padding: EdgeInsets.all(2.0),
              child: Icon(Icons.close_rounded, size: 14, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
