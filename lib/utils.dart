import 'package:intl/intl.dart';


String dateToString(DateTime date) => '${date.day}.${date.month}';

String getFormattedPrice(int price) => '${NumberFormat("#,##0").format(price)}₪';

String phoneNumberToString(int phoneNumber) => '0$phoneNumber';