import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/services/cloud_services.dart';


String dateToString(DateTime date) => '${date.day}.${date.month}';

String getFormattedPrice(int price) => '${NumberFormat("#,##0").format(price)}₪';

String phoneNumberToString(int phoneNumber) => '0$phoneNumber';

int getDaysDifference(DateTime lower, DateTime upper) {
  return DateTime(upper.year, upper.month, upper.day).difference(DateTime(lower.year, lower.month, lower.day)).inDays;
}

Map<String, double> getLatLngSquare(double lat, double lng){
  double distance = 200; //in meters
  double latOffset = distance / 111000;
  double lngOffset = distance / (111320 * cos(lat * pi / 180));

  double minLat = lat - latOffset;
  double maxLat = lat + latOffset;
  double minLng = lng - lngOffset;
  double maxLng = lng + lngOffset;

  return {'minLat': minLat, 'minLng': minLng, 'maxLat': maxLat, 'maxLng': maxLng};
}
