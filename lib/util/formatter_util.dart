import 'package:intl/intl.dart';

class FormatterUtil {
  /// Format number to Indonesian locale with thousand separator
  /// Example: 72000 -> "72.000"
  static String formatPrice(dynamic value) {
    int intValue;

    if (value is String) {
      intValue = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    } else if (value is int) {
      intValue = value;
    } else if (value is double) {
      intValue = value.toInt();
    } else {
      intValue = 0;
    }

    final formatter = NumberFormat('#,##0', 'id_ID');
    return formatter.format(intValue);
  }

  /// Format number with Rp prefix
  /// Example: 72000 -> "Rp. 72.000"
  static String formatPriceWithCurrency(dynamic value) {
    return 'Rp. ${formatPrice(value)}';
  }
}
