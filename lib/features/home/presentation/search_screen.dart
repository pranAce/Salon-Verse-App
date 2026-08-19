import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/app/config/api_config.dart';
import 'package:salonverse/features/salons/services/salon_provider.dart';
import 'package:salonverse/features/auth/services/auth_provider.dart';
import 'package:salonverse/features/booking/services/booking_provider.dart';
import 'package:salonverse/features/salons/models/salon_model.dart';
import 'package:salonverse/features/salons/models/nearby_service_model.dart';
import 'package:salonverse/core/utils/currency_formatter.dart';
import 'package:salonverse/core/widgets/sv_cards.dart';
import 'package:salonverse/core/widgets/sv_button.dart';
import 'package:salonverse/core/widgets/sv_feedback_states.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final String? initialCategory;

  const SearchScreen({super.key, this.initialQuery, this.initialCategory});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late TabController _tabController;

  final List<String> _popularSuggestions = const [
    'Hair Cut',
    'Facial Treatment',
    'Gel Nails',
    'Swedish Massage',
    'Bridal Makeup',
    'Hair Coloring',
    'Manicure',
    'Keratin Treatment',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<SalonProvider>();
      prov.loadRecentSearches();

      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        _searchController.text = widget.initialQuery!;
        prov.updateSearchQuery(widget.initialQuery!);
      } else if (widget.initialCategory != null &&
          widget.initialCategory!.isNotEmpty &&
          widget.initialCategory != 'All') {
        prov.selectCategory(widget.initialCategory!);
      } else if (prov.searchQuery.isNotEmpty) {
        _searchController.text = prov.searchQuery;
      }

      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _focusNode.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _submitSearch(String term) {
    if (term.trim().isEmpty) return;
    _searchController.text = term;
    _focusNode.unfocus();
    final prov = context.read<SalonProvider>();
    prov.addRecentSearch(term);
    prov.updateSearchQuery(term);
  }

  void _clearSearch() {
    _searchController.clear();
    final prov = context.read<SalonProvider>();
    prov.clearSearch();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final salonProv = context.watch<SalonProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    final query = _searchController.text.trim();
    final isSearching = query.isNotEmpty;
    final matchingSalons = salonProv.filteredSalons;
    final matchingServices = salonProv.nearbyServices;
    final isLoading = salonProv.isLoading || salonProv.isNearbyLoading;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        leadingWidth: 46,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        titleSpacing: 0,
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceElevated
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: _submitSearch,
            onChanged: (val) {
              setState(() {});
              salonProv.updateSearchQuery(val);
            },
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search salons, styling, nails, spa...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              suffixIcon: query.isNotEmpty
                  ? GestureDetector(
                      onTap: _clearSearch,
                      child: Icon(
                        Icons.cancel_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        bottom: isSearching
            ? PreferredSize(
                preferredSize: const Size.fromHeight(42),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2.5,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    Tab(text: 'Salons (${matchingSalons.length})'),
                    Tab(text: 'Services (${matchingServices.length})'),
                  ],
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: !isSearching
            ? _buildSearchSuggestionsView(salonProv, isDark)
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildSalonsResultList(
                    matchingSalons,
                    isLoading,
                    user,
                    isDark,
                    salonProv,
                  ),
                  _buildServicesResultList(matchingServices, isLoading, isDark),
                ],
              ),
      ),
    );
  }

  Widget _buildSearchSuggestionsView(SalonProvider salonProv, bool isDark) {
    final recentSearches = salonProv.recentSearches;

    return ListView(
      padding: const EdgeInsets.all(18),
      physics: const BouncingScrollPhysics(),
      children: [
        if (recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  salonProv.clearRecentSearches();
                },
                child: Text(
                  'Clear All',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: recentSearches.map((term) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 0,
                  ),
                  leading: const Icon(
                    Icons.history_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    term,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                    onPressed: () => salonProv.removeRecentSearch(term),
                  ),
                  onTap: () => _submitSearch(term),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
        ],

        Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Popular Treatments',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: _popularSuggestions.map((term) {
            return GestureDetector(
              onTap: () => _submitSearch(term),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                  boxShadow: isDark ? null : AppSpacing.softShadow(context),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      term,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.north_east_rounded,
                      size: 13,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSalonsResultList(
    List<SalonModel> salons,
    bool isLoading,
    dynamic user,
    bool isDark,
    SalonProvider salonProv,
  ) {
    if (isLoading && salons.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: 4,
        itemBuilder: (context, index) => SVSkeleton.salonCardSkeleton(context),
      );
    }

    if (salons.isEmpty) {
      return SVEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No Salons Found',
        description:
            'No venues match "${_searchController.text}". Check spelling or try a different term.',
        actionLabel: 'Clear Search',
        onAction: _clearSearch,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: salons.length,
      itemBuilder: (context, index) {
        final salon = salons[index];
        final isFav = user?.favoriteSalons.contains(salon.id) ?? false;
        return SVSalonCard(
          salon: salon,
          isFavorite: isFav,
          onTap: () =>
              context.push('/salon/${salon.id}', extra: {'salon': salon}),
          onFavoriteToggle: () {
            context.read<AuthProvider>().toggleFavorite(salon.id);
          },
        );
      },
    );
  }

  Widget _buildServicesResultList(
    List<NearbyServiceModel> services,
    bool isLoading,
    bool isDark,
  ) {
    if (isLoading && services.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: 5,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: SVSkeleton(
            width: double.infinity,
            height: 72,
            borderRadius: 14,
          ),
        ),
      );
    }

    if (services.isEmpty) {
      return SVEmptyState(
        icon: Icons.content_cut_outlined,
        title: 'No Treatments Found',
        description: 'No specific services match "${_searchController.text}".',
        actionLabel: 'Clear Search',
        onAction: _clearSearch,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        final salonLogoUrl = service.salonLogo.isNotEmpty
            ? ApiConfig.resolveImageUrl(service.salonLogo)
            : (service.salon.imageUrl.isNotEmpty
                  ? ApiConfig.resolveImageUrl(service.salon.imageUrl)
                  : '');

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: isDark ? null : AppSpacing.softShadow(context),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: salonLogoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: salonLogoUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: isDark
                                ? AppColors.darkSurfaceElevated
                                : AppColors.lightSurfaceSecondary,
                          ),
                          errorWidget: (context, url, err) =>
                              const SVFallbackLogo(logoSize: 24, padding: 8),
                        )
                      : const SVFallbackLogo(logoSize: 24, padding: 8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.serviceName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${service.salonName} • ${service.durationMinutes} mins',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.formatNPR(service.price),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SVButton(
                    text: 'Book',
                    size: SVButtonSize.sm,
                    onPressed: () {
                      final bk = context.read<BookingProvider>();
                      bk.startBookingFlow(service.salon, service.service);
                      context.push('/booking-flow');
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
