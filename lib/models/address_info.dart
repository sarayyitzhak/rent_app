import 'package:cloud_firestore/cloud_firestore.dart';

class AddressInfo {
  final GeoPoint _geoPoint;
  final String? _city;
  final String? _road;

  AddressInfo({required GeoPoint geoPoint, required String? city, required String? road})
      : _geoPoint = geoPoint,
        _city = city,
        _road = road;

  GeoPoint get geoPoint => _geoPoint;

  String? get city => _city;

  String? get road => _road;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AddressInfo && runtimeType == other.runtimeType && _geoPoint == other.geoPoint;

  @override
  int get hashCode => _geoPoint.hashCode;

  String addressDataToString() {
    return '${_city ?? ''}${(_road != null && _road != '') ? ',  $_road' : ''}';
  }

  Map<String, dynamic> toMap() {
    return {
      'geoPoint': _geoPoint,
      'city': _city ?? '',
      'road': _road ?? '',
    };
  }

  factory AddressInfo.fromMap(Map<String, dynamic> map) {
    return AddressInfo(geoPoint: map['geoPoint'], city: map['city'], road: map['road']);
  }
}
