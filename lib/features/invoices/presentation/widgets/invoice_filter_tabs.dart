import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_filter_bar.dart';

/// All / Paid / Due / Partial / Overdue filter for the invoice list.
/// Same thin-wrapper pattern as [StockFilterTabs] / [OrderFilterTabs].
class InvoiceFilterTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const InvoiceFilterTabs({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomFilterBar<String>(
      filters: const ['all', 'paid', 'due', 'partial', 'overdue'],
      selectedFilters: {selected},
      labelBuilder: (f) => switch (f) {
        'all' => AppStrings.invoiceFilterAll,
        'paid' => AppStrings.invoiceStatusPaid,
        'due' => AppStrings.invoiceStatusDue,
        'partial' => AppStrings.invoiceStatusPartial,
        _ => AppStrings.invoiceStatusOverdue,
      },
      onSelected: onChanged,
    );
  }
}