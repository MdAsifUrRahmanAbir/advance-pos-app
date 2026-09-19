/// Computes concrete start/end dates for the Invoices quick-filter date
/// chips. Both dates are midnight-normalized (time-of-day stripped)
/// since the API is expected to take date-only values.
class InvoiceDatePresets {
  InvoiceDatePresets._();

  static const keys = ['today', 'yesterday', 'last7days', 'thisMonth', 'lastMonth'];

  static ({DateTime start, DateTime end}) rangeFor(String presetKey) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (presetKey) {
      case 'today':
        return (start: today, end: today);
      case 'yesterday':
        final yesterday = today.subtract(const Duration(days: 1));
        return (start: yesterday, end: yesterday);
      case 'last7days':
        return (start: today.subtract(const Duration(days: 6)), end: today);
      case 'thisMonth':
        return (start: DateTime(now.year, now.month, 1), end: today);
      case 'lastMonth':
        final firstOfThisMonth = DateTime(now.year, now.month, 1);
        final lastDayOfLastMonth = firstOfThisMonth.subtract(const Duration(days: 1));
        return (start: DateTime(lastDayOfLastMonth.year, lastDayOfLastMonth.month, 1), end: lastDayOfLastMonth);
      default:
        return (start: today, end: today);
    }
  }
}