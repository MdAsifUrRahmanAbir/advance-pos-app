import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_filter_bar.dart';
import '../states/invoice_date_presets.dart';

/// Single combined quick-filter row: payment status (All/Paid/Due/
/// Partial — client-side over loaded data) and date presets (Today/
/// Yesterday/Last 7 Days/This Month/Last Month — server-side, refetches
/// via [InvoicesController.selectDatePreset]). Both axes are
/// independent and can be active simultaneously (e.g. "Paid" + "This
/// Month"), so [CustomFilterBar]'s `selectedFilters` set carries both
/// selected keys at once rather than being mutually exclusive across
/// the whole row.
class InvoiceQuickFilterTabs extends StatelessWidget {
  final String selectedStatus;
  final String? selectedDatePreset;
  final ValueChanged<String> onStatusSelected;
  final ValueChanged<String?> onDatePresetSelected;

  const InvoiceQuickFilterTabs({
    super.key,
    required this.selectedStatus,
    required this.selectedDatePreset,
    required this.onStatusSelected,
    required this.onDatePresetSelected,
  });

  static const _statusKeys = ['all', 'paid', 'due', 'partial'];

  @override
  Widget build(BuildContext context) {
    final allKeys = [..._statusKeys, ...InvoiceDatePresets.keys];
    final selected = <String>{
      selectedStatus,
      if (selectedDatePreset != null) selectedDatePreset!,
    };

    return CustomFilterBar<String>(
      filters: allKeys,
      selectedFilters: selected,
      labelBuilder: (key) => switch (key) {
        'all' => AppStrings.filterAll,
        'paid' => AppStrings.invoicePaidLabel,
        'due' => AppStrings.invoiceDueLabel,
        'partial' => AppStrings.invoiceStatusPartial,
        'today' => AppStrings.invoiceDatePresetToday,
        'yesterday' => AppStrings.invoiceDatePresetYesterday,
        'last7days' => AppStrings.invoiceDatePresetLast7Days,
        'thisMonth' => AppStrings.invoiceDatePresetThisMonth,
        _ => AppStrings.invoiceDatePresetLastMonth,
      },
      onSelected: (key) {
        if (_statusKeys.contains(key)) {
          onStatusSelected(key);
        } else {
          onDatePresetSelected(selectedDatePreset == key ? null : key);
        }
      },
    );
  }
}