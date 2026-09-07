import 'package:flutter/material.dart';
import 'package:template_test/core/constants/app_colors.dart';
import 'package:template_test/core/constants/app_sizes.dart';

import '../../theme/app_color_scheme.dart';

class CustomFilterBar<T> extends StatelessWidget {
  final List<T> filters;
  final Set<T> selectedFilters;
  final String Function(T) labelBuilder;
  final ValueChanged<T>? onSelected;
  final VoidCallback? onClear;

  const CustomFilterBar({
    super.key,
    required this.filters,
    required this.selectedFilters,
    required this.labelBuilder,
    this.onSelected,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...filters.map(
            (filter) => Padding(
              padding: const EdgeInsets.only(right: AppSizes.sm),
              child: FilterChip(
                label: Text(labelBuilder(filter)),
                selected: selectedFilters.contains(filter),
                onSelected: (_) => onSelected?.call(filter),
                selectedColor: AppColors.primaryLight,
                checkmarkColor: AppColors.primary,
                side: const BorderSide(color: AppColors.border),
                showCheckmark: false,
              ),
            ),
          ),
          if (onClear != null)
            ActionChip(
              label: const Text('Clear'),
              onPressed: onClear,
              backgroundColor: context.appColors.surface,
              side: const BorderSide(color: AppColors.border),
            ),
        ],
      ),
    );
  }
}
