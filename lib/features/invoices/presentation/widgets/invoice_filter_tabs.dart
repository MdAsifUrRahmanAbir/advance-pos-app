import 'package:flutter/material.dart';
import '../../../../core/widgets/common/custom_filter_bar.dart';

/// All / Paid / Due / Partial filter — status is derived client-side
/// per-page (see [InvoiceStatusBadge.statusOf]) since the API returns
/// no status field, so this filters only the currently loaded page.
class InvoiceFilterTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const InvoiceFilterTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomFilterBar<String>(
      filters: const ['all', 'paid', 'due', 'partial'],
      selectedFilters: {selected},
      labelBuilder: (f) => switch (f) {
        'all' => 'All',
        'paid' => 'Paid',
        'due' => 'Due',
        _ => 'Partial',
      },
      onSelected: onChanged,
    );
  }
}
