class DateFormatter {
  DateFormatter._();

  static String format(DateTime date) => date.toIso8601String();
}
