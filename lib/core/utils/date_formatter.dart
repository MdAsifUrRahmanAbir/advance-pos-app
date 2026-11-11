import '../constants/app_strings.dart';

class DateFormatter {
  DateFormatter._();

  static String format(DateTime date) => date.toIso8601String();

  /// "08-11-2026", "08/11/2026", optionally followed by " 14:30[:00]".
  static final RegExp _dayFirst = RegExp(
    r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})(?:[ T](\d{1,2}):(\d{2})(?::\d{2})?)?$',
  );

  static const int _hoursHalfDay = 12;

  /// Reads an API date: day-first ("08-11-2026[ 14:30]") or ISO
  /// ("2026-11-08[T14:30:00]"). [hasTime] is false when only a date was
  /// sent. Null when the value can't be read.
  static ({DateTime value, bool hasTime})? tryParseApi(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    final m = _dayFirst.firstMatch(text);
    if (m != null) {
      final hour = m.group(4);
      return (
      value: DateTime(
        int.parse(m.group(3)!),
        int.parse(m.group(2)!),
        int.parse(m.group(1)!),
        hour == null ? 0 : int.parse(hour),
        hour == null ? 0 : int.parse(m.group(5)!),
      ),
      hasTime: hour != null,
      );
    }

    final iso = DateTime.tryParse(text);
    if (iso == null) return null;
    return (value: iso, hasTime: text.contains(':'));
  }

  /// "08 Nov 2026", or "08 Nov 2026 at 2:30 PM" when [raw] has a time.
  /// Unreadable values are returned as they are.
  static String displayDateTime(String raw) {
    final parsed = tryParseApi(raw);
    if (parsed == null) return raw;
    final d = parsed.value;
    final date = '${d.day.toString().padLeft(2, '0')} '
        '${AppStrings.monthShortNames[d.month - 1]} ${d.year}';
    if (!parsed.hasTime) return date;

    final hour12 = d.hour % _hoursHalfDay == 0 ? _hoursHalfDay : d.hour % _hoursHalfDay;
    final period = d.hour < _hoursHalfDay ? AppStrings.timeAm : AppStrings.timePm;
    final time = '$hour12:${d.minute.toString().padLeft(2, '0')} $period';
    return AppStrings.dateAtTime(date, time);
  }
}