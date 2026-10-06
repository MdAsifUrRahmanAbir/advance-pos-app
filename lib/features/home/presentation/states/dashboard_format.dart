import '../../../../core/constants/app_strings.dart';

/// Display formatting for dashboard numbers.
/// TODO: replace with core/utils/currency_formatter.dart if it covers
/// integer + compact formatting, so the app has one money formatter.
class DashboardFormat {
  const DashboardFormat._();

  /// 121491 -> ৳121,491 · -17960 -> -৳17,960
  static String money(double value) {
    final digits = value.abs().round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
    );
    final sign = value < 0 ? '-' : '';
    return '$sign${AppStrings.dashCurrencySymbol}$digits';
  }

  /// 542168.95 -> 542.2k · 1371954 -> 1.4M · 800 -> 800 (chart axis labels)
  static String compact(double value) {
    String trim(double v) =>
        v.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');

    final abs = value.abs();
    if (abs >= 1000000) return '${trim(value / 1000000)}M';
    if (abs >= 1000) return '${trim(value / 1000)}k';
    return value.round().toString();
  }
}