import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_filter_bar.dart';
import '../states/invoice_date_presets.dart';

/// Single combined quick-filter row: payment status (All/Paid/Due/
/// Partial — client-side over loaded data) and date presets (Today/
/// Yesterday/Last 7 Days/This Month/Last Month — server-side, refetches
/// via [InvoicesController.selectDatePreset]). The row is single-select
/// overall — picking either a status chip or a date-preset chip clears
/// the other axis (see [InvoicesController.selectStatus] /
/// [selectDatePreset]), so only one chip is ever highlighted at a time.
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

    // Single-select: if a date preset is active, only IT is highlighted
    // (not also the default 'all' status chip); otherwise the status
    // chip is highlighted.
    final selected = <String>{
      selectedDatePreset ?? selectedStatus,
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