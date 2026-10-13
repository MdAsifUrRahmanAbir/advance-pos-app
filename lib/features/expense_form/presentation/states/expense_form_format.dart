/// Date and amount formatting for the expense form.
// TODO: promote amount()/total() to core/utils/currency_formatter.dart.
class ExpenseFormFormat {
  const ExpenseFormFormat._();

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// DateTime -> 'DD-MM-YYYY' (request body).
  static String payloadDate(DateTime d) =>
      '${_two(d.day)}-${_two(d.month)}-${d.year.toString().padLeft(4, '0')}';

  /// Tolerant parse of the server's expense_date: 'DD-MM-YYYY',
  /// 'DD/MM/YY', 'YYYY-MM-DD'. Returns null when it can't be read.
  static DateTime? parseServerDate(String raw) {
    final parts = raw
        .trim()
        .split(RegExp(r'[^0-9]+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length < 3) return null;
    final a = int.tryParse(parts[0]);
    final b = int.tryParse(parts[1]);
    final c = int.tryParse(parts[2]);
    if (a == null || b == null || c == null) return null;

    final yearFirst = parts[0].length == 4;
    final day = yearFirst ? c : a;
    var year = yearFirst ? a : c;
    if (year < 100) year += 2000;
    if (b < 1 || b > 12 || day < 1 || day > 31) return null;
    return DateTime(year, b, day);
  }

  /// Line amount: 1000 -> 1,000 · 1250.5 -> 1,250.50
  static String amount(num value) =>
      _format(value, value == value.roundToDouble() ? 0 : 2);

  /// Total: always two decimals, e.g. 1,100.00 (as on the web form).
  static String total(num value) => _format(value, 2);

  static String _format(num value, int decimals) {
    final parts = value.abs().toStringAsFixed(decimals).split('.');
    final grouped = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
    );
    final sign = value < 0 ? '-' : '';
    final fraction = parts.length > 1 ? '.${parts[1]}' : '';
    return '$sign$grouped$fraction';
  }
}