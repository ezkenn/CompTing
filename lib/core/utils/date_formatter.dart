import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static String shortDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  static String dateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  static String dayMonth(DateTime date) {
    return DateFormat('dd MMM', 'id_ID').format(date);
  }

  static String dueRelative(DateTime dueDate, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    final target = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = target.difference(today).inDays;

    if (diff < 0) {
      return 'Terlambat ${diff.abs()} hari';
    }
    if (diff == 0) {
      return 'Jatuh tempo hari ini';
    }
    if (diff <= 3) {
      return 'H-$diff jatuh tempo';
    }
    return 'Sisa $diff hari';
  }
}
