import '../../../../core/utils/currency_formatter.dart';
import '../../data/model/sales_bill_preview_model.dart';

/// Pure formatting for the Bill Preview receipt (no state, no UI).
/// "Present" means not null, not blank and not the literal "null" — rows
/// whose value is not present are hidden on the receipt.
class SalesBillPreviewFormat {
  SalesBillPreviewFormat._();

  static const int _fractionDigits = 2;
  static const int _groupSize = 3;
  static const int _hoursPerHalfDay = 12;
  static const int _yearDigitsModulo = 100;
  static const int _pad = 2;
  static const String _am = 'AM';
  static const String _pm = 'PM';

  static bool isPresent(Object? value) {
    if (value == null) return false;
    final text = value.toString().trim();
    return text.isNotEmpty && text.toLowerCase() != 'null';
  }

  /// Trimmed text, or null when the value is not present.
  static String? text(Object? value) =>
      isPresent(value) ? value.toString().trim() : null;

  static double number(Object? value) =>
      isPresent(value) ? parseAmount(value.toString()) : 0;

  static bool isNonZero(Object? value) => isPresent(value) && number(value) != 0;

  /// "1200" -> "1,200.00"
  static String amount(Object? value) => grouped(number(value));

  static String grouped(double value) {
    final parts = value.abs().toStringAsFixed(_fractionDigits).split('.');
    final digits = parts.first;
    final buffer = StringBuffer(value < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % _groupSize == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    buffer.write('.${parts.last}');
    return buffer.toString();
  }

  /// Negative amounts print in parentheses: -0.4 -> "(0.40)".
  static String accounting(double value) =>
      value < 0 ? '(${grouped(value.abs())})' : grouped(value);

  /// "3.00" -> "3", "1.50" -> "1.5"
  static String quantity(Object? value) {
    final n = number(value);
    if (n == n.roundToDouble()) return n.round().toString();
    return n.toString();
  }

  /// "31/10/26 05:38 PM" — same shape as the server's bill date.
  static String stamp(DateTime d) {
    String two(int n) => n.toString().padLeft(_pad, '0');
    final hour = d.hour % _hoursPerHalfDay == 0
        ? _hoursPerHalfDay
        : d.hour % _hoursPerHalfDay;
    final period = d.hour < _hoursPerHalfDay ? _am : _pm;
    return '${two(d.day)}/${two(d.month)}/${two(d.year % _yearDigitsModulo)} '
        '${two(hour)}:${two(d.minute)} $period';
  }

  /// "NAME (detail)" — detail dropped when not present.
  static String withDetail(String name, Object? detail, {bool square = false}) {
    final extra = text(detail);
    if (extra == null) return name;
    return square ? '$name [$extra]' : '$name ($extra)';
  }

  /// One method: its name. Split payment: "Cash (1,000.00), Nagad (966.00)".
  static String? paidBy(List<Payment> payments) {
    final named = payments.where((p) => isPresent(p.paymentName)).toList();
    if (named.isEmpty) return null;
    if (named.length == 1) return text(named.first.paymentName);
    return named
        .map((p) => withDetail(text(p.paymentName)!, amount(p.collectionAmount)))
        .join(', ');
  }
}