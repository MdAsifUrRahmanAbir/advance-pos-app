import 'package:flutter/material.dart';

import '../../../../core/widgets/common/custom_filter_bar.dart';

/// All / Electronics / Clothing / Home / Sports category filter.
/// Purely presentational — reports the selected category up via
/// [onChanged].
class StockCategoryTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const StockCategoryTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const categories = [
    'All',
    'Low Stock',
    'Out of Stock',
    'Best Selling',
    'Fast Moving',
    'Slow Moving',
  ];

  @override
  Widget build(BuildContext context) {
    return CustomFilterBar<String>(
      filters: categories,
      selectedFilters: {selected},
      labelBuilder: (c) => c,
      onSelected: onChanged,
    );
  }
}
