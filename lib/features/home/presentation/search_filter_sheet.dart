import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/salons/services/salon_provider.dart';
import 'package:salonverse/shared/design_system/sv_button.dart';

class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({super.key});

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late String _selectedCategory;
  late String _selectedSort;
  String _selectedCity = 'All Locations';
  RangeValues _priceRange = const RangeValues(200, 4500);
  double _minRating = 0.0;

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Hair', 'icon': Icons.content_cut_rounded},
    {'name': 'Skin', 'icon': Icons.face_retouching_natural_rounded},
    {'name': 'Nails', 'icon': Icons.spa_rounded},
    {'name': 'Massage', 'icon': Icons.self_improvement_rounded},
    {'name': 'Makeup', 'icon': Icons.brush_rounded},
    {'name': 'Spa', 'icon': Icons.hot_tub_rounded},
  ];

  final List<Map<String, dynamic>> _sortOptions = const [
    {'id': 'recommended', 'label': 'Recommended', 'icon': Icons.auto_awesome_rounded},
    {'id': 'rating', 'label': 'Top Rated', 'icon': Icons.star_rounded},
    {'id': 'nearest', 'label': 'Nearest', 'icon': Icons.near_me_rounded},
    {'id': 'price_asc', 'label': 'Best Price', 'icon': Icons.sell_rounded},
  ];

  final List<String> _cities = const [
    'All Locations',
    'Kathmandu',
    'Lalitpur',
    'Bhaktapur',
    'Pokhara',
  ];

  final List<Map<String, dynamic>> _ratings = const [
    {'value': 0.0, 'label': 'Any'},
    {'value': 3.5, 'label': '3.5+'},
    {'value': 4.0, 'label': '4.0+'},
    {'value': 4.5, 'label': '4.5+'},
  ];

  @override
  void initState() {
    super.initState();
    final prov = context.read<SalonProvider>();
    _selectedCategory = prov.selectedCategory.isEmpty ? 'All' : prov.selectedCategory;
    _selectedSort = prov.selectedSort.isEmpty ? 'recommended' : prov.selectedSort;
    _selectedCity = prov.selectedCity.isEmpty ? 'All Locations' : prov.selectedCity;
    _minRating = prov.minRating;
    _priceRange = RangeValues(
      prov.minPrice > 0 ? prov.minPrice : 200,
      prov.maxPrice < 10000 ? prov.maxPrice : 4500,
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedCategory != 'All') count++;
    if (_selectedSort != 'recommended') count++;
    if (_selectedCity != 'All Locations') count++;
    if (_minRating > 0.0) count++;
    if (_priceRange.start > 200 || _priceRange.end < 4500) count++;
    return count;
  }

  void _resetFilters() {
    HapticFeedback.lightImpact();
    context.read<SalonProvider>().clearAllFilters();
    setState(() {
      _selectedCategory = 'All';
      _selectedSort = 'recommended';
      _selectedCity = 'All Locations';
      _priceRange = const RangeValues(200, 4500);
      _minRating = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final salonProv = context.watch<SalonProvider>();
    final activeCount = _getActiveFilterCount();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 100 : 30),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF383535) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Filter & Refine',
                        style: GoogleFonts.outfit(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      if (activeCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$activeCount',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (activeCount > 0)
                    GestureDetector(
                      onTap: _resetFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Reset All',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceElevated : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                children: [
                  // 1. Service Category
                  _buildSectionTitle('Category', 'Filter by specialty & treatment', isDark),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final name = cat['name'] as String;
                        final icon = cat['icon'] as IconData;
                        final isSel = _selectedCategory == name;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildCategoryChip(name, icon, isSel, isDark),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 2. Sort Order
                  _buildSectionTitle('Sort By', 'Choose salon ranking criteria', isDark),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.7,
                    children: _sortOptions.map((opt) {
                      final id = opt['id'] as String;
                      final label = opt['label'] as String;
                      final icon = opt['icon'] as IconData;
                      final isSel = _selectedSort == id;
                      return _buildSortTile(id, label, icon, isSel, isDark);
                    }).toList(),
                  ),

                  const SizedBox(height: 22),

                  // 3. Location / City
                  _buildSectionTitle('Location', 'Select city or operational area', isDark),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _cities.map((city) {
                      final isSel = _selectedCity == city;
                      return _buildCityChip(city, isSel, isDark);
                    }).toList(),
                  ),

                  const SizedBox(height: 22),

                  // 4. Price Budget Range
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Budget Range', 'Filter by service price', isDark),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Rs. ${_priceRange.start.round()} - ${_priceRange.end.round()}',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: isDark ? AppColors.darkBorder : Colors.grey.shade200,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withAlpha(40),
                      trackHeight: 5,
                      rangeThumbShape: const RoundRangeSliderThumbShape(
                        enabledThumbRadius: 10,
                        elevation: 3,
                      ),
                    ),
                    child: RangeSlider(
                      values: _priceRange,
                      min: 100,
                      max: 5000,
                      divisions: 49,
                      onChanged: (vals) => setState(() => _priceRange = vals),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 5. Minimum Rating
                  _buildSectionTitle('Rating', 'Minimum customer satisfaction score', isDark),
                  const SizedBox(height: 10),
                  Row(
                    children: _ratings.map((r) {
                      final val = r['value'] as double;
                      final label = r['label'] as String;
                      final isSel = _minRating == val;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _minRating = val);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSel
                                    ? AppColors.primary
                                    : (isDark ? AppColors.darkSurfaceElevated : Colors.grey.shade50),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSel
                                      ? AppColors.primary
                                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                  width: isSel ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (val > 0) ...[
                                    Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: isSel ? Colors.white : const Color(0xFFF59E0B),
                                    ),
                                    const SizedBox(width: 3),
                                  ],
                                  Text(
                                    label,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: isSel
                                          ? Colors.white
                                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Bottom Sticky Apply Button
            Container(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: SVButton(
                text: 'Show Salons',
                icon: Icons.check_circle_outline_rounded,
                isFullWidth: true,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  salonProv.applyFilters(
                    category: _selectedCategory,
                    sort: _selectedSort,
                    city: _selectedCity,
                    minPrice: _priceRange.start,
                    maxPrice: _priceRange.end,
                    minRating: _minRating,
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String name, IconData icon, bool isSel, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedCategory = name);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel
              ? AppColors.primary
              : (isDark ? AppColors.darkSurfaceElevated : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSel
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : Colors.transparent),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSel ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isSel
                    ? Colors.white
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortTile(String id, String label, IconData icon, bool isSel, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedSort = id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSel
              ? (isDark ? const Color(0xFF361421) : AppColors.primaryTint)
              : (isDark ? AppColors.darkSurfaceElevated : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSel
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSel ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSel
                    ? AppColors.primary
                    : (isDark ? AppColors.darkSurface : Colors.white),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 13,
                color: isSel ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                  color: isSel
                      ? AppColors.primary
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityChip(String city, bool isSel, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedCity = city);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel
              ? AppColors.primary
              : (isDark ? AppColors.darkSurfaceElevated : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSel
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 13,
              color: isSel ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              city,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                color: isSel
                    ? Colors.white
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
