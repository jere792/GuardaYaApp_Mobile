import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'es_PE', symbol: 'S/').format(amount);
  }

  static String generateUuid() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           '_' + (1000 + DateTime.now().microsecond).toString();
  }

  static DateTime? parseIsoDate(String? isoDate) {
    if (isoDate == null) return null;
    return DateTime.tryParse(isoDate);
  }

  static String toIsoDate(DateTime? date) {
    if (date == null) return DateTime.now().toIso8601String();
    return date.toIso8601String();
  }
}
