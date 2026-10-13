import 'package:flutter/material.dart';

/// Opens the system calendar for a manual date range. Returns null when the
/// user cancels.
Future<DateTimeRange?> showExpenseDateRangePicker({
  required BuildContext context,
  DateTimeRange? current,
}) {
  const yearsBack = 5;
  const yearsForward = 1;
  final now = DateTime.now();
  return showDateRangePicker(
    context: context,
    firstDate: DateTime(now.year - yearsBack),
    lastDate: DateTime(now.year + yearsForward, 12, 31),
    initialDateRange: current,
  );
}