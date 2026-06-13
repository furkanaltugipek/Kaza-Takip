import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _displayFormat = DateFormat('dd MMM yyyy', 'tr_TR');
  static final DateFormat _storageFormat = DateFormat('yyyy-MM-dd');

  static String toDisplay(DateTime date) => _displayFormat.format(date);
  static String toStorage(DateTime date) => _storageFormat.format(date);

  static DateTime fromStorage(String raw) =>
      _storageFormat.parse(raw);

  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Returns the streak-relevant "yesterday" in local time.
  static DateTime yesterday() => today().subtract(const Duration(days: 1));

  /// Number of whole years between two dates (for age display).
  static int yearsBetween(DateTime from, DateTime to) {
    int years = to.year - from.year;
    if (to.month < from.month ||
        (to.month == from.month && to.day < from.day)) {
      years--;
    }
    return years.clamp(0, 999);
  }
}
