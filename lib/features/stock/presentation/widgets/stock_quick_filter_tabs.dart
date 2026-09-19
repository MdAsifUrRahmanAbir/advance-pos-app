import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_filter_bar.dart';
import '../../../master_data/data/models/category_model.dart';

/// Single quick-filter row combining the client-side status filter
/// (All / In Stock / Out of Stock, applied over already-loaded items)
/// with server-side top-category shortcuts (sourced from master data's
/// `categoryData.topCategories`, applied via a fresh API call with
/// `category_id`). Visually one continuous [CustomFilterBar] so both
/// feel like the same "quick filter" affordance, even though status
/// and category filtering work differently underneath.
///
/// Selecting a category clears the active status back to "All" (since
/// a category filter narrows the server-side result set the status
/// tabs then act on); selecting a status clears any active category.
/// Only one chip in the whole row is ever selected at a time.
class StockQuickFilterTabs extends StatelessWidget {
  final String selectedStatus;
  final int? selectedCategoryId;
  final List<TopCategory> topCategories;
  final ValueChanged<String> onStatusSelected;
  final ValueChanged<int?> onCategorySelected;

  const StockQuickFilterTabs({
    super.key,
    required this.selectedStatus,
    required this.selectedCategoryId,
    required this.topCategories,
    required this.onStatusSelected,
    required this.onCategorySelected,
  });

  static const _statusKeys = ['all', 'inStock', 'outOfStock'];

  String _categoryKey(int id) => 'category:$id';

  @override
  Widget build(BuildContext context) {
    final allKeys = [
      ..._statusKeys,
      for (final category in topCategories) _categoryKey(category.categoryId),
    ];

    final selectedKey = selectedCategoryId != null ? _categoryKey(selectedCategoryId!) : selectedStatus;

    return CustomFilterBar<String>(
      filters: allKeys,
      selectedFilters: {selectedKey},
      labelBuilder: (key) {
        switch (key) {
          case 'all':
            return AppStrings.stockFilterAll;
          case 'inStock':
            return AppStrings.stockFilterInStock;
          case 'outOfStock':
            return AppStrings.stockFilterOutOfStock;
          default:
            final id = int.parse(key.split(':').last);
            final category = topCategories.firstWhere((c) => c.categoryId == id);
            return category.categoryName;
        }
      },
      onSelected: (key) {
        if (_statusKeys.contains(key)) {
          onCategorySelected(null);
          onStatusSelected(key);
        } else {
          final id = int.parse(key.split(':').last);
          onCategorySelected(id);
        }
      },
    );
  }
}