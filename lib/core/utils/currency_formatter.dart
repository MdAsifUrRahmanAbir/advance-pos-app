class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount, {String symbol = '৳'}) =>
      "$symbol${amount.toStringAsFixed(2)}";
}


double parseAmount(String value) {
  final cleaned = value.replaceAll(',', '').trim();
  return double.tryParse(cleaned) ?? 0;
}

int parseQuantity(String value) {
  final cleaned = value.replaceAll(',', '').trim();
  return double.tryParse(cleaned)?.round() ?? 0;
}