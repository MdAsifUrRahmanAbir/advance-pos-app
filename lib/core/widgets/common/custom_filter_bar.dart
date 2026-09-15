import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_sizes.dart';
import '../../theme/app_color_scheme.dart';
import '../../utils/widget_animation_extension.dart';

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
          ...filters.asMap().entries.map((entry) {
            final index = entry.key;
            final filter = entry.value;

            return Padding(
              padding: const EdgeInsets.only(right: AppSizes.sm),
              child: FilterChip(
                label: Text(labelBuilder(filter)),
                selected: selectedFilters.contains(filter),
                onSelected: (_) => onSelected?.call(filter),
                selectedColor: context.appColors.surface,
                checkmarkColor: context.appColors.primary,
                side: BorderSide(color: context.appColors.border),
              ).fadeSlideIn(delay: (index * 100).ms),
            );
          }),
          if (onClear != null)
            ActionChip(
              label: const Text('Clear'),
              onPressed: onClear,
              backgroundColor: context.appColors.surface,
              side: BorderSide(color: context.appColors.border),
            ),
        ],
      ),
    );
  }
}
