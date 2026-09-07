import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_filter_bar.dart';

/// Category chips (All / Beverages / Snacks / Grocery).
/// Reuses CustomFilterBar as a single-select bar via a one-item Set —
/// this is the widget's intended use case (category filtering), so it
/// should track the Figma pill-chip look closely.
class CategoryFilterBar extends StatelessWidget {
  final String selectedCategory; // 'all' | 'beverages' | 'snacks' | 'grocery'
  final ValueChanged<String> onCategoryChanged;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  static const _keys = <String>['all', 'beverages', 'snacks', 'grocery'];

  String _labelFor(String key) => switch (key) {
    'beverages' => AppStrings.categoryBeverages,
    'snacks' => AppStrings.categorySnacks,
    'grocery' => AppStrings.categoryGrocery,
    _ => AppStrings.categoryAll,
  };

  @override
  Widget build(BuildContext context) {
    return CustomFilterBar<String>(
      filters: _keys,
      selectedFilters: {selectedCategory},
      labelBuilder: _labelFor,
      onSelected: (key) {
        if (key != selectedCategory) onCategoryChanged(key);
      },
    );
  }
}