import 'package:intl/intl.dart';

class AppDateUtils {
  static String getDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  static String getShortDayName(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  static String getFormattedDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  static String getMonthYear(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }

  static String getDayMonth(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static List<DateTime> getWeekDays(DateTime startDate) {
    return List.generate(7, (index) => startDate.add(Duration(days: index)));
  }
}