import 'package:flutter/material.dart';

/// Opens the system calendar for a manual date range, allowing dates from
/// [_yearsBack] years ago to the end of next year. Returns null when the
/// user cancels. Shared by every list with a "Custom Range" date filter.
Future<DateTimeRange?> showAppDateRangePicker({
  required BuildContext context,
  DateTimeRange? current,
}) {
  final now = DateTime.now();
  return showDateRangePicker(
    context: context,
    firstDate: DateTime(now.year - _yearsBack),
    lastDate: DateTime(now.year + _yearsForward, DateTime.december, _lastDay),
    initialDateRange: current,
  );
}

const int _yearsBack = 5;
const int _yearsForward = 1;
const int _lastDay = 31;
