import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/utility/custom_filter_bar.dart';

/// Today / This Week / This Month filter for the activity feed.
class ActivityFilterTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const ActivityFilterTabs({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomFilterBar<String>(
      filters: const ['today', 'week', 'month'],
      selectedFilters: {selected},
      labelBuilder: (f) => switch (f) {
        'today' => AppStrings.filterToday,
        'week' => AppStrings.filterThisWeek,
        _ => AppStrings.filterThisMonth,
      },
      onSelected: onChanged,
    );
  }
}