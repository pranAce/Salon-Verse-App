import 'package:flutter/material.dart';
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
  String _selectedQuickFilter = 'All';

  final List<String> _quickFilters = const [
    'All',
    'Top Rated',
    'Near Me',
    'Home Service',
  ];

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SearchFilterSheet(),
    );
  }

  void _onQuickFilterSelected(String filter, SalonProvider prov) {
    setState(() => _selectedQuickFilter = filter);
    if (filter == 'All') {
      prov.applyFilters(minRating: 0.0, sort: 'recommended', homeServiceOnly: false);
    } else if (filter == 'Top Rated') {
      prov.applyFilters(minRating: 4.5, sort: 'rating');
    } else if (filter == 'Near Me') {
      prov.applyFilters(sort: 'nearest');
    } else if (filter == 'Home Service') {
      prov.applyFilters(homeServiceOnly: true);
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

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore Salons',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              '${list.length} verified venues found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filter Salons',
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => salonProv.fetchSalons(forceRefresh: true),
          color: AppColors.primary,
          child: Column(
            children: [
              // Search Field
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
                child: SVSearchField(
                  controller: _searchController,
                  hintText: 'Search salon, service, or area...',
                  onChanged: (val) => salonProv.updateSearchQuery(val),
                  onClear: () {
                    _searchController.clear();
                    salonProv.clearSearch();
                  },
                  onFilterTap: _openFilterSheet,
                ),
              ),

              // Quick Filter Chips
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: _quickFilters.length,
                  itemBuilder: (context, index) {
                    final filter = _quickFilters[index];
                    final isSel = _selectedQuickFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SVCFilterChip(
                        label: filter,
                        isSelected: isSel,
                        onSelected: () => _onQuickFilterSelected(filter, salonProv),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Salons List
              Expanded(
                child: salonProv.isLoading && list.isEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        itemCount: 4,
                        itemBuilder: (context, _) => SVSkeleton.salonCardSkeleton(context),
                      )
                    : list.isEmpty
                        ? SVEmptyState(
                            icon: Icons.storefront_outlined,
                            title: 'No Salons Found',
                            description:
                                'No venues match your criteria. Try adjusting your search query or active filters.',
                            actionLabel: 'Reset All Filters',
                            onAction: () {
                              _searchController.clear();
                              setState(() => _selectedQuickFilter = 'All');
                              salonProv.clearAllFilters();
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(18, 6, 18, 80),
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
}
