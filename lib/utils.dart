import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


String dateToString(DateTime date) => '${date.day}.${date.month}';

String getFormattedPrice(int price) => '${NumberFormat("#,##0").format(price)}₪';

String phoneNumberToString(int phoneNumber) => '0$phoneNumber';

int getDaysDifference(DateTime lower, DateTime upper) {
  return DateTime(upper.year, upper.month, upper.day).difference(DateTime(lower.year, lower.month, lower.day)).inDays;
}

List<DateTime> getDateList(DateTimeRange range) {
  List<DateTime> dates = [];
  DateTime fromDate = range.start;
  while (!range.end.isBefore(fromDate)) {
    dates.add(fromDate);
    fromDate = fromDate.add(const Duration(days: 1));
  }
  return dates;
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

String getNextAlphabeticalString(String input) {
  List<int> chars = List.of(input.codeUnits);
  chars[chars.length - 1]++;
  return String.fromCharCodes(chars);
}

String getDifferenceInTimeAsString(BuildContext context, DateTime time){
  Duration duration = DateTime.now().difference(time);
  if(duration.inMinutes < 60){
    return duration.inMinutes == 0 ? 'לפני מס׳ שניות' : 'לפני ${duration.inMinutes} דקות';
  } else if(duration.inHours < 24){
    return 'לפני ${duration.inHours} שעות';
  } else if(duration.inDays < 30){
    return 'לפני ${duration.inDays} ימים';
  } else if(duration.inDays < 365){
    return 'לפני ${duration.inDays / 30} חודשים';
  } else {
    return 'לפני ${duration.inDays / 365} שנים';
  }
}