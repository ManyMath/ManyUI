/// Bespoke date parsing/formatting for [MDateField].
///
/// v0.1 deliberately ships without `intl` to keep the runtime-deps budget at
/// 3/4. The accepted-input set is narrow but covers the three most common
/// keyboard idioms a user types into a date field:
///
/// - **ISO** — `2026-05-13`. Month and day are zero-padded.
/// - **US slash** — `5/13/2026` or `05/13/2026`. Month-first; the year is
///   four digits.
/// - **English month names** — `May 13 2026`, `May 13, 2026`, `13 May 2026`,
///   `13 May, 2026`. Case-insensitive. Both three-letter and full names are
///   accepted (`May` and `may`; `Sep` and `September`).
///
/// Returned [DateTime] is at UTC midnight on the parsed date — only the
/// year/month/day slots are meaningful; the time-zone offset is a side effect
/// of choosing UTC for the constructor.
///
/// All return values are normalized via the calendar so e.g. `2026-02-30`
/// returns `null` rather than rolling over to March 2nd.
library;

const List<String> _monthNamesLong = <String>[
  'january',
  'february',
  'march',
  'april',
  'may',
  'june',
  'july',
  'august',
  'september',
  'october',
  'november',
  'december',
];

const List<String> _monthNamesShort = <String>[
  'jan',
  'feb',
  'mar',
  'apr',
  'may',
  'jun',
  'jul',
  'aug',
  'sep',
  'oct',
  'nov',
  'dec',
];

/// Returns the parsed [DateTime] or `null` if [raw] is empty or doesn't
/// match one of the accepted formats.
///
/// Whitespace surrounding [raw] is trimmed before parsing.
DateTime? parseMDate(String raw) {
  final String s = raw.trim();
  if (s.isEmpty) return null;

  final DateTime? iso = _parseIso(s);
  if (iso != null) return iso;

  final DateTime? slash = _parseSlash(s);
  if (slash != null) return slash;

  final DateTime? word = _parseWordy(s);
  if (word != null) return word;

  return null;
}

/// Returns the canonical ISO-8601 date string `YYYY-MM-DD` for [date].
///
/// Only the year/month/day slots are read.
String formatMDate(DateTime date) {
  final String y = date.year.toString().padLeft(4, '0');
  final String m = date.month.toString().padLeft(2, '0');
  final String d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime? _parseIso(String s) {
  // YYYY-MM-DD with hyphens required and 4-2-2 digits.
  if (s.length != 10) return null;
  if (s[4] != '-' || s[7] != '-') return null;
  final int? y = int.tryParse(s.substring(0, 4));
  final int? m = int.tryParse(s.substring(5, 7));
  final int? d = int.tryParse(s.substring(8, 10));
  if (y == null || m == null || d == null) return null;
  return _build(y, m, d);
}

DateTime? _parseSlash(String s) {
  // M/D/YYYY or MM/DD/YYYY. Two slashes, three numeric fields, year 4 digits.
  final List<String> parts = s.split('/');
  if (parts.length != 3) return null;
  final int? m = int.tryParse(parts[0]);
  final int? d = int.tryParse(parts[1]);
  final int? y = int.tryParse(parts[2]);
  if (m == null || d == null || y == null) return null;
  if (parts[2].length != 4) return null;
  return _build(y, m, d);
}

DateTime? _parseWordy(String s) {
  // Comma is optional; treat it as a soft separator.
  final String cleaned = s.replaceAll(',', ' ');
  final List<String> tokens = cleaned
      .split(RegExp(r'\s+'))
      .where((String t) => t.isNotEmpty)
      .toList();
  if (tokens.length != 3) return null;

  int? month;
  int? day;
  int? year;

  for (int i = 0; i < tokens.length; i++) {
    final String t = tokens[i].toLowerCase();
    final int? asMonth = _monthIndex(t);
    if (asMonth != null) {
      if (month != null) return null;
      month = asMonth + 1;
      continue;
    }
    final int? asInt = int.tryParse(t);
    if (asInt == null) return null;
    // Heuristic: a 4-digit token is the year; otherwise it's the day. This
    // means 2-digit years like '99' are rejected — by design for v0.1.
    if (tokens[i].length == 4) {
      if (year != null) return null;
      year = asInt;
    } else {
      if (day != null) return null;
      day = asInt;
    }
  }

  if (month == null || day == null || year == null) return null;
  return _build(year, month, day);
}

int? _monthIndex(String token) {
  for (int i = 0; i < _monthNamesLong.length; i++) {
    if (_monthNamesLong[i] == token) return i;
  }
  for (int i = 0; i < _monthNamesShort.length; i++) {
    if (_monthNamesShort[i] == token) return i;
  }
  return null;
}

DateTime? _build(int y, int m, int d) {
  if (m < 1 || m > 12) return null;
  if (d < 1 || d > 31) return null;
  if (y < 1 || y > 9999) return null;
  final DateTime candidate = DateTime.utc(y, m, d);
  // Reject calendar overflow (e.g. Feb 30 rolling forward into March).
  if (candidate.year != y ||
      candidate.month != m ||
      candidate.day != d) {
    return null;
  }
  return candidate;
}

/// Returns the month name at [monthIndex] (1-12), used in the calendar
/// popover header.
String monthName(int monthIndex) {
  if (monthIndex < 1 || monthIndex > 12) return '';
  return _monthNamesLong[monthIndex - 1][0].toUpperCase() +
      _monthNamesLong[monthIndex - 1].substring(1);
}

/// Returns the short weekday name for [weekday] (DateTime.monday..sunday),
/// used in the calendar header row. Sunday-start convention: Sun, Mon, …, Sat.
String shortWeekdayName(int weekday) {
  const List<String> names = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  if (weekday < 1 || weekday > 7) return '';
  return names[weekday - 1];
}
