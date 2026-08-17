import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonverse/features/salons/services/salon_provider.dart';
import 'package:salonverse/core/widgets/app_button.dart';

class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({super.key});

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  String _selectedCity = 'All';
  RangeValues _priceRange = const RangeValues(200, 3000);
  double _minRating = 4.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final salonProvider = context.read<SalonProvider>();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Filters',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Location',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['All', 'Kathmandu', 'Lalitpur'].map((city) {
              final isSel = _selectedCity == city;
              return ChoiceChip(
                label: Text(city),
                selected: isSel,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCity = city;
                    });
                  }
                },
                selectedColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSel
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          Text(
            'Price Range (Rs.)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          RangeSlider(
            values: _priceRange,
            min: 200,
            max: 5000,
            divisions: 24,
            activeColor: theme.colorScheme.primary,
            labels: RangeLabels(
              'Rs. ${_priceRange.start.round()}',
              'Rs. ${_priceRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rs. ${_priceRange.start.round()}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                'Rs. ${_priceRange.end.round()}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Minimum Rating',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [4.0, 4.5, 4.7, 4.8].map((rate) {
              final isSel = _minRating == rate;
              return InkWell(
                onTap: () {
                  setState(() {
                    _minRating = rate;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSel
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: isSel
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: isSel ? Colors.white : Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$rate+',
                        style: TextStyle(
                          color: isSel
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),

          AppButton(
            label: "Apply Filters",
            onPressed: () {
              salonProvider.fetchSalons();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
