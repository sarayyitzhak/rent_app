import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AddressService {
  static final AddressService _instance = AddressService._internal();
  static const int kMaxRadius = 10; /* in meters */

  final Map<GeoPoint, String> _addresses = {};

  AddressService._internal();

  factory AddressService() {
    return _instance;
  }

  Future<String?> getAddress(GeoPoint geoPoint) async {
    for (GeoPoint addressGeoPoint in _addresses.keys) {
      double distance = Geolocator.distanceBetween(
          geoPoint.latitude,
          geoPoint.longitude,
          addressGeoPoint.latitude,
          addressGeoPoint.longitude);
      if (distance < kMaxRadius) {
        return _addresses[addressGeoPoint];
      }
    }

    String? address;

    List<Placemark> placeMarks = await placemarkFromCoordinates(
      geoPoint.latitude,
      geoPoint.longitude,
    );

    if (placeMarks.isNotEmpty) {
      Placemark place = placeMarks[0];
      if ((place.locality ?? '').isNotEmpty) {
        address = place.locality;
        if ((place.thoroughfare ?? '').isNotEmpty) {
          address = '$address, ${place.thoroughfare}';
        }
      } else if ((place.country ?? '').isNotEmpty) {
        address = place.country;
      }
    }

    if (address != null) {
      _addresses[geoPoint] = address;
    }

    return address;
  }
}
