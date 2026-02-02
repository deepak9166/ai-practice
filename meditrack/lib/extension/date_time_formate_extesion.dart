import 'package:intl/intl.dart';

/// Extension on String: Parse date strings + directly format to pretty strings
extension DateTimeStringExtension on String {
  /// Parse with explicit format (your existing method)
  DateTime toDateTime({required String format, String? locale}) {
    try {
      return DateFormat(format, locale).parseStrict(this);
    } catch (e) {
      throw FormatException('Cannot parse "$this" with pattern "$format"', e);
    }
  }

  /// NEW: Parse using common default formats automatically
  /// Tries multiple popular formats in order. Returns DateTime if any matches.
  /// Throws FormatException only if ALL attempts fail.
  DateTime toDateTimeDefault({String? locale}) {
    final commonFormats = [
      'yyyy-MM-dd', // 2026-01-07
      'dd/MM/yyyy', // 07/01/2026
      'MM/dd/yyyy', // 01/07/2026
      'dd-MM-yyyy', // 07-01-2026
      'yyyy/MM/dd', // 2026/01/07
      'dd MMM yyyy', // 07 Jan 2026
      'MMM dd, yyyy', // Jan 07, 2026
      'EEEE, MMMM dd, yyyy', // Wednesday, January 07, 2026
      'yyyy-MM-ddTHH:mm:ss', // 2026-01-07T14:30:00 (ISO without Z)
      'yyyy-MM-dd HH:mm:ss', // 2026-01-07 14:30:00
    ];

    for (final pattern in commonFormats) {
      try {
        return DateFormat(pattern, locale).parseStrict(this);
      } catch (_) {
        // Continue trying next format
      }
    }

    // If nothing worked, fall back to ISO 8601 auto-parse (very forgiving)
    try {
      return DateTime.parse(this.trim());
    } catch (_) {
      // Final failure
    }

    throw FormatException(
      'Cannot parse date string "$this" with any common format',
    );
  }

  /// Convenience: Auto-parse ISO 8601 (most common backend format)
  DateTime toDateTimeAuto() => DateTime.parse(this.trim());

  bool isSameDay() {
    var today = DateTime.now();
    var itemDate = DateTime.parse(trim());
    if (today.day == itemDate.day &&
        today.month == itemDate.month &&
        today.year == itemDate.year) {
      return true;
    } else {
      return false;
    }
  }

  // ────────────────────────────────
  // Direct formatting: String → Pretty Date String
  // ────────────────────────────────

  /// "Wed, Jan 7"
  String toShortDayMonth({String? locale}) {
    final dt = toDateTimeAuto();
    return DateFormat('E, MMM d', locale).format(dt);
  }

  /// "Wed, Jan 7, 2026"
  String toShortDayMonthYear({String? locale}) {
    final dt = toDateTimeAuto();
    return DateFormat('E, MMM d, y', locale).format(dt);
  }

  /// "Wednesday, January 7"
  String toFullDayMonth({String? locale}) {
    final dt = toDateTimeAuto();
    return DateFormat('EEEE, MMMM d', locale).format(dt);
  }

  /// "Wednesday, January 7, 2026"
  String toFullDayMonthYear({String? locale}) {
    final dt = toDateTimeAuto();
    return DateFormat('EEEE, MMMM d, y', locale).format(dt);
  }

  /// "Jan 7, 2026"
  String toMonthDayYear({String? locale}) {
    final dt = toDateTimeAuto();
    return DateFormat('MMM d, yyyy', locale).format(dt);
  }

  /// "7 Jan 2026"
  String toDayMonthYear({String? locale}) {
    final dt = toDateTimeAuto();
    return DateFormat('d MMM yyyy', locale).format(dt);
  }

  /// "Wed, Jan 7 • 2:30 PM"
  String toShortWithTime({String? locale}) {
    final dt = toDateTimeAuto();
    return DateFormat('E, MMM d • h:mm a', locale).format(dt);
  }

  /// "Wednesday, Jan 7 at 2:30 PM"
  String toFullWithTime({String? locale}) {
    final dt = toDateTimeAuto();
    return DateFormat('EEEE, MMM d \'at\' h:mm a', locale).format(dt);
  }

  /// Relative: "Today", "Tomorrow", "Yesterday" or fallback to "Wed, Jan 7"
  String toRelativeDay({String? locale}) {
    final dt = toDateTimeAuto().toLocal();
    final now = DateTime.now().toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);

    if (date == today) return 'Today';
    if (date == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';

    return DateFormat('E, MMM d', locale).format(dt);
  }
}

/// Extension on DateTime: Rich formatting options
extension DateTimeFormatExtension on DateTime {
  String format(String pattern, {String? locale}) =>
      DateFormat(pattern, locale).format(this);

  String get shortDayMonth => format('E, MMM d'); // Wed, Jan 7
  String get shortDayMonthYear => format('E, MMM d, y'); // Wed, Jan 7, 2026
  String get fullDayMonth => format('EEEE, MMMM d'); // Wednesday, January 7
  String get fullDayMonthYear =>
      format('EEEE, MMMM d, y'); // Wednesday, January 7, 2026
  String get monthDayYear => format('MMM d, yyyy'); // Jan 7, 2026
  String get dayMonthYear => format('d MMM yyyy'); // 7 Jan 2026
  String get shortWithTime =>
      format('E, MMM d • h:mm a'); // Wed, Jan 7 • 2:30 PM
  String get fullWithTime =>
      format('EEEE, MMM d \'at\' h:mm a'); // Wednesday, Jan 7 at 2:30 PM
  String get timeOnly => format('h:mm a'); // 2:30 PM
  String get isoDate => format('yyyy-MM-dd'); // 2026-01-07
}
