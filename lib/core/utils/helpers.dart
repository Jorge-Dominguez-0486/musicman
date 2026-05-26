import 'package:intl/intl.dart';

String formatPrice(double price) {
  final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);
  return formatter.format(price);
}

String formatDate(DateTime date) {
  final formatter = DateFormat('d MMM yyyy');
  return formatter.format(date);
}

String shortId(String id) {
  if (id.length <= 8) return id.toUpperCase();
  return id.substring(0, 8).toUpperCase();
}
