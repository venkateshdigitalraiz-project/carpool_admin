import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('EEE, d MMM').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('EEE, d MMM • hh:mm a').format(dateTime);
  }

  static String formatFullDate(DateTime dateTime) {
    return DateFormat('EEEE, d MMMM yyyy').format(dateTime);
  }

  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0 && remainingMinutes > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${remainingMinutes}m';
    }
  }

  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return formatter.format(amount);
  }
}
