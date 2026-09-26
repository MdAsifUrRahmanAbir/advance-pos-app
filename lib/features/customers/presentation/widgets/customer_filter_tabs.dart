import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_filter_bar.dart';
import '../states/customer_type.dart';

class CustomerFilterTabs extends StatelessWidget {
  final String selectedType; // 'all' | '1' | '2' | '3'
  final ValueChanged<String> onTypeSelected;

  const CustomerFilterTabs({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  static const _knownTypeKeys = ['1', '2', '3'];

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