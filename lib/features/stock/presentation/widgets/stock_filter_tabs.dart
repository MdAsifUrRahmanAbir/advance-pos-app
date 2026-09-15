import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_filter_bar.dart';

/// All / In Stock / Low Stock / Out of Stock / Slow Moving filter for
/// the stock report list. Mirrors [ProductCategoryTabs] / [OrderFilterTabs]
/// — a thin [CustomFilterBar] wrapper owning only its own label mapping.
class StockFilterTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const StockFilterTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomFilterBar<String>(
      filters: const ['all', 'inStock', 'lowStock', 'outOfStock', 'slowMoving'],
      selectedFilters: {selected},
      labelBuilder: (f) => switch (f) {
        'all' => AppStrings.stockFilterAll,
        'inStock' => AppStrings.stockFilterInStock,
        'lowStock' => AppStrings.stockFilterLowStock,
        'outOfStock' => AppStrings.stockFilterOutOfStock,
        _ => AppStrings.stockFilterSlowMoving,
      },
      onSelected: onChanged,
    );
  }
}
