class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount, {String symbol = '\$'}) => "$symbol${amount.toStringAsFixed(2)}";
}