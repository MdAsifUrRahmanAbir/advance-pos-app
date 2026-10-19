import '../../../../core/constants/app_strings.dart';
import 'sales_return_state.dart';

class SalesReturnFormat {
  const SalesReturnFormat._();

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// DateTime -> 'YYYY-MM-DD'.
  static String apiDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

  /// 'YYYY-MM-DD to YYYY-MM-DD', or null unless both dates exist (the API
  /// ignores a half-filled range).
  static String? dateRange(DateTime? from, DateTime? to) =>
      from == null || to == null ? null : '${apiDate(from)} to ${apiDate(to)}';

  static String presetLabel(SalesReturnDatePreset preset) {
    switch (preset) {
      case SalesReturnDatePreset.all:
        return AppStrings.filterAll;
      case SalesReturnDatePreset.today:
        return AppStrings.invoiceDatePresetToday;
      case SalesReturnDatePreset.yesterday:
        return AppStrings.invoiceDatePresetYesterday;
      case SalesReturnDatePreset.last7Days:
        return AppStrings.invoiceDatePresetLast7Days;
      case SalesReturnDatePreset.thisMonth:
        return AppStrings.invoiceDatePresetThisMonth;
      case SalesReturnDatePreset.lastMonth:
        return AppStrings.invoiceDatePresetLastMonth;
      case SalesReturnDatePreset.custom:
        return AppStrings.expDateCustomRange;
    }
  }
}