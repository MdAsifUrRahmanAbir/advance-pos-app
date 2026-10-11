import '../../../../core/constants/app_strings.dart';
import '../../data/model/expense_detail_model.dart' show ResultData;
import 'expense_state.dart';

/// Display formatting for the Expense feature.
/// TODO: money() mirrors DashboardFormat.money — promote one shared
/// formatter to core/utils/currency_formatter.dart.
class ExpenseFormat {
  const ExpenseFormat._();

  /// 150 -> ৳150 · 1250.5 -> ৳1,250.50
  static String money(num value) {
    final isWhole = value == value.roundToDouble();
    final parts = value.abs().toStringAsFixed(isWhole ? 0 : 2).split('.');
    final grouped = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
    );
    final sign = value < 0 ? '-' : '';
    final decimals = parts.length > 1 ? '.${parts[1]}' : '';
    return '$sign${AppStrings.dashCurrencySymbol}$grouped$decimals';
  }

  /// DateTime -> 'YYYY-MM-DD' for from_date / to_date.
  static String apiDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

  static String orDash(String? value) =>
      (value == null || value.trim().isEmpty)
          ? AppStrings.expEmptyValue
          : value.trim();

  static String presetLabel(ExpenseDatePreset preset) => switch (preset) {
    ExpenseDatePreset.all => AppStrings.expAllDates,
    ExpenseDatePreset.today => AppStrings.expDateToday,
    ExpenseDatePreset.yesterday => AppStrings.expDateYesterday,
    ExpenseDatePreset.last7Days => AppStrings.expDateLast7Days,
    ExpenseDatePreset.thisMonth => AppStrings.expDateThisMonth,
    ExpenseDatePreset.lastMonth => AppStrings.expDateLastMonth,
    ExpenseDatePreset.custom => AppStrings.expDateCustomRange,
  };

  /// Plain-text summary for the Share action.
  static String shareText(
      ResultData d,
      String Function(int systemId, int accountId) accountLabelOf,
      ) {
    final b = StringBuffer()
      ..writeln('${AppStrings.expExpenseNo}: ${d.expenseNo}')
      ..writeln('${AppStrings.expExpenseDate}: ${d.expenseDate}')
      ..writeln('${AppStrings.expOutlet}: ${d.branchName}')
      ..writeln('${AppStrings.expAmount}: ${money(d.totalAmount)}')
      ..writeln()
      ..writeln('${AppStrings.expExpenseHeads}:');

    for (var i = 0; i < d.details.length; i++) {
      final h = d.details[i];
      b.writeln('${i + 1}. ${h.headName} - ${money(h.amount)}');
      b.writeln(
        '   ${accountLabelOf(h.paymentSystemId, h.paymentAccId)}',
      );
      if (h.localNarration.trim().isNotEmpty) {
        b.writeln('   ${h.localNarration.trim()}');
      }
    }

    b
      ..writeln()
      ..write('${AppStrings.expTotal}: ${money(d.totalAmount)}');

    if (d.globalNarration.trim().isNotEmpty) {
      b
        ..writeln()
        ..write('${AppStrings.expGlobalNarration}: ${d.globalNarration.trim()}');
    }
    return b.toString();
  }
}