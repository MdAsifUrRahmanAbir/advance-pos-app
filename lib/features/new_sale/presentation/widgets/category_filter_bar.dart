import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_filter_bar.dart';
import '../../../master_data/data/models/category_model.dart';

/// Category quick-filter — "All" plus top-selling categories sourced
/// from master data's `categoryData.topCategories` (same source as
/// Stock's quick-category chips), applied server-side via `category_id`.
class CategoryFilterBar extends StatelessWidget {
  final int? selectedCategoryId; // null = All
  final List<TopCategory> topCategories;
  final ValueChanged<int?> onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategoryId,
    required this.topCategories,
    required this.onCategorySelected,
  });

  String _key(int? id) => id == null ? 'all' : 'category:$id';

  @override
  Widget build(BuildContext context) {
    final allKeys = ['all', for (final c in topCategories) 'category:${c.categoryId}'];
    final selectedKey = _key(selectedCategoryId);

    return CustomFilterBar<String>(
      filters: allKeys,
      selectedFilters: {selectedKey},
      labelBuilder: (key) {
        if (key == 'all') return AppStrings.categoryAll;
        final id = int.parse(key.split(':').last);
        return topCategories.firstWhere((c) => c.categoryId == id).categoryName;
      },
      onSelected: (key) {
        onCategorySelected(key == 'all' ? null : int.parse(key.split(':').last));
      },
    );
  }
}