import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_filter_bar.dart';
import '../states/customer_type.dart';

/// Quick client-side filter row — All / Regular / Special (types 1 & 2).
/// Add more keys to `_knownTypeKeys` once more types are confirmed.
class CustomerFilterTabs extends StatelessWidget {
  final String selectedType; // 'all' | '1' | '2' | ...
  final ValueChanged<String> onTypeSelected;

  const CustomerFilterTabs({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  static const _knownTypeKeys = ['1', '2'];

  @override
  Widget build(BuildContext context) {
    final allKeys = ['all', ..._knownTypeKeys];

    return CustomFilterBar<String>(
      filters: allKeys,
      selectedFilters: {selectedType},
      labelBuilder: (key) => key == 'all' ? AppStrings.filterAll : customerTypeLabel(int.parse(key)),
      onSelected: onTypeSelected,
    );
  }
}