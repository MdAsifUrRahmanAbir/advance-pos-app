import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_filter_bar.dart';

/// Today / Weekly / Monthly period switch for the dashboard.
///
/// NOTE: `CustomFilterBar` is a multi-select FilterChip bar (Set<T> based),
/// not a single-select segmented tab control. This wraps it to emulate
/// single-select via a one-item Set, but the visual result is a row of
/// filter chips — it will NOT match the boxed segmented-tab look from the
/// Figma mockup. If that exact visual is required, a dedicated
/// SegmentedTabBar core widget would need to be added (flagging for your
/// review rather than adding unilaterally).
class DashboardPeriodFilter extends StatelessWidget {
  final String selectedPeriod; // 'today' | 'weekly' | 'monthly'
  final ValueChanged<String> onPeriodChanged;

  const DashboardPeriodFilter({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  static const _keys = <String>['today', 'weekly', 'monthly'];

  String _labelFor(String key) => switch (key) {
    'weekly' => AppStrings.periodWeekly,
    'monthly' => AppStrings.periodMonthly,
    _ => AppStrings.periodToday,
  };

  @override
  Widget build(BuildContext context) {
    return CustomFilterBar<String>(
      filters: _keys,
      selectedFilters: {selectedPeriod},
      labelBuilder: _labelFor,
      onSelected: (key) {
        // Force single-select: ignore taps on the already-selected chip,
        // since CustomFilterBar's onSelected fires per-chip toggle intent.
        if (key != selectedPeriod) onPeriodChanged(key);
      },
    );
  }
}