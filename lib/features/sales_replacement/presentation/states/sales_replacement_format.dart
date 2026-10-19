import '../../../../core/constants/app_strings.dart';
import 'sales_replacement_state.dart';

class SalesReplacementFormat {
  const SalesReplacementFormat._();

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// DateTime -> 'YYYY-MM-DD'.
  static String apiDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

  /// 'YYYY-MM-DD to YYYY-MM-DD', or null unless both dates exist (the API
  /// ignores a half-filled range).
  static String? dateRange(DateTime? from, DateTime? to) =>
      from == null || to == null ? null : '${apiDate(from)} to ${apiDate(to)}';

  static String presetLabel(SalesReplacementDatePreset preset) {
    switch (preset) {
      case SalesReplacementDatePreset.all:
        return AppStrings.filterAll;
      case SalesReplacementDatePreset.today:
        return AppStrings.invoiceDatePresetToday;
      case SalesReplacementDatePreset.yesterday:
        return AppStrings.invoiceDatePresetYesterday;
      case SalesReplacementDatePreset.last7Days:
        return AppStrings.invoiceDatePresetLast7Days;
      case SalesReplacementDatePreset.thisMonth:
        return AppStrings.invoiceDatePresetThisMonth;
      case SalesReplacementDatePreset.lastMonth:
        return AppStrings.invoiceDatePresetLastMonth;
      case SalesReplacementDatePreset.custom:
        return AppStrings.expDateCustomRange;
    }
  }
}