class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount) => "\$${amount.toStringAsFixed(2)}";
}
