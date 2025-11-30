import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String toIso8601StringUtc() {
    return toUtc().toIso8601String();
  }

  String get toYMD {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  String get toHM {
    return DateFormat('HH:mm').format(this);
  }
  
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
