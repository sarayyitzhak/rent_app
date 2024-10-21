import 'package:intl/intl.dart';


String dateToString(DateTime date) => '${date.day}.${date.month}';

String getFormattedPrice(int price) => '${NumberFormat("#,##0").format(price)}₪';

String phoneNumberToString(int phoneNumber) => '0$phoneNumber';

int getDaysDifference(DateTime lower, DateTime upper) {
  return DateTime(upper.year, upper.month, upper.day).difference(DateTime(lower.year, lower.month, lower.day)).inDays;
}