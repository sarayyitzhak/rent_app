import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:rent_app/models/file_data.dart';
import 'package:rent_app/services/cloud_services.dart';


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

Future<FileData> getFileData(Reference fileRef, [String fileExtension = 'jpg']) async {
  Uint8List? fileData;

  try {
    FileInfo? cachedFile = await DefaultCacheManager().getFileFromMemory(fileRef.fullPath);

    if (cachedFile != null) {
      fileData = await cachedFile.file.readAsBytes();
    } else {
      cachedFile = await DefaultCacheManager().getFileFromCache(fileRef.fullPath);

      if (cachedFile != null) {
        fileData = await cachedFile.file.readAsBytes();
      } else {
        fileData = await readFile(fileRef, fileExtension);
      }
    }
  } catch (e) {
    fileData = null;
  }

  return FileData.fromDataAndReference(fileData, fileRef);
}

String generateRandomString(int length) {
  const characters = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final random = Random();
  return List.generate(length, (index) => characters[random.nextInt(characters.length)]).join();
}

bool areListsEqual<T>(List<T> list1, List<T> list2) {
  if (list1.length != list2.length) return false;
  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) return false;
  }
  return true;
}