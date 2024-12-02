import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class CurrentPositionService {
  static final CurrentPositionService _instance = CurrentPositionService._internal();

  CurrentPositionNotifier currentPositionNotifier = CurrentPositionNotifier();
  String? _currentCityName;

  CurrentPositionService._internal();

  factory CurrentPositionService() {
    return _instance;
  }

  GeoPoint? get geoPoint => currentPositionNotifier.geoPoint;

  CurrentPositionPermission get permission => currentPositionNotifier.permission;

  Future<void> init() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      currentPositionNotifier.updatePermission(CurrentPositionPermission.serviceDisabled);
      return;
    }

    await _updateCurrentPosition(await Geolocator.checkPermission());
  }

  Future<void> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      currentPositionNotifier.updatePermission(CurrentPositionPermission.serviceDisabled);
      return;
    }

    await _updateCurrentPosition(await Geolocator.requestPermission());
  }

  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  void updateGeoPoint(GeoPoint geoPoint) {
    _currentCityName = null;
    currentPositionNotifier.updateGeoPoint(geoPoint);
  }

  Future<String?> getCurrentCityName() async {
    if (_currentCityName != null) {
      return _currentCityName;
    }
    if (currentPositionNotifier.geoPoint == null) {
      return null;
    }
    List<Placemark> placeMarks = await placemarkFromCoordinates(
      currentPositionNotifier.geoPoint!.latitude,
      currentPositionNotifier.geoPoint!.longitude,
    );

    if (placeMarks.isNotEmpty) {
      Placemark place = placeMarks[0];
      _currentCityName = place.locality;
      if (_currentCityName != null) {
        if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          _currentCityName = '$_currentCityName, ${place.thoroughfare}';
        }
      } else {
        _currentCityName = place.country;
      }
    }
    return _currentCityName;
  }

  double? getDistanceFromCurrentPosition(GeoPoint geoPoint) {
    if (this.geoPoint == null) {
      return null;
    } else {
      return Geolocator.distanceBetween(this.geoPoint!.latitude, this.geoPoint!.longitude, geoPoint.latitude, geoPoint.longitude);
    }
  }

  Future<void> _updateCurrentPosition(LocationPermission permission) async {
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      currentPositionNotifier.updatePermission(CurrentPositionPermission.denied);
    } else if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      GeoPoint geoPoint = GeoPoint(position.latitude, position.longitude);
      _currentCityName = null;
      currentPositionNotifier.updateGeoPointAndPermission(geoPoint, CurrentPositionPermission.granted);
    } else {
      currentPositionNotifier.updatePermission(CurrentPositionPermission.unknown);
    }
  }
}

class CurrentPositionNotifier extends ChangeNotifier {
  final CurrentPosition _value = CurrentPosition();

  void updateGeoPoint(GeoPoint? geoPoint) {
    if (_value.geoPoint?.latitude == geoPoint?.latitude && _value.geoPoint?.longitude == geoPoint?.longitude) {
      return;
    }
    _value.geoPoint = geoPoint;
    notifyListeners();
  }

  void updatePermission(CurrentPositionPermission permission) {
    if (_value.permission == permission) {
      return;
    }
    _value.permission = permission;
    notifyListeners();
  }

  void updateGeoPointAndPermission(GeoPoint? geoPoint, CurrentPositionPermission permission) {
    if (_value.permission == permission &&
        _value.geoPoint?.latitude == geoPoint?.latitude &&
        _value.geoPoint?.longitude == geoPoint?.longitude) {
      return;
    }
    _value.geoPoint = geoPoint;
    _value.permission = permission;
    notifyListeners();
  }

  GeoPoint? get geoPoint => _value.geoPoint;

  CurrentPositionPermission get permission => _value.permission;
}

class CurrentPosition {
  GeoPoint? geoPoint;
  CurrentPositionPermission permission = CurrentPositionPermission.unknown;
}

enum CurrentPositionPermission { serviceDisabled, denied, granted, unknown }
