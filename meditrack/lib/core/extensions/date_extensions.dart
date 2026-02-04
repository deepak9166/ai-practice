import 'package:intl/intl.dart';

extension DateConverter on DateTime {
  /// 04 Feb 2026
  String toDDMMMYYYY() {
    return DateFormat('dd MMM yyyy').format(this);
  }

  /// 04/02/2026
  String toDDMMYYYY() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// 2026-02-04 (API / DB friendly)
  String toYYYYMMDD() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  /// 04 Feb, 10:30 AM
  String toReadableDateTime() {
    return DateFormat('dd MMM, hh:mm a').format(this);
  }

  /// 10:30 AM (for reminder time)
  String toTime12Hour() {
    return DateFormat('hh:mm a').format(this);
  }

  /// 22:30 (24 hour)
  String toTime24Hour() {
    return DateFormat('HH:mm').format(this);
  }

  /// Monday, Tuesday...
  String toWeekday() {
    return DateFormat('EEEE').format(this);
  }

  /// Feb 2026 (for monthly expense view)
  String toMonthYear() {
    return DateFormat('MMM yyyy').format(this);
  }

  /// Check if date is today
  bool isToday() {
    final now = DateTime.now();
    return year == now.year &&
        month == now.month &&
        day == now.day;
  }
}
