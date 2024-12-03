import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/models/request_status.dart';
import 'item_extension_request.dart';

class ItemRequest {
  final DocumentReference _docRef;
  final String _ownerID;
  final String _applicantID;
  final String _itemID;
  final RequestStatus _status;
  final DateTimeRange _time;
  final ItemExtensionRequest? _extensionRequest;
  final int _price;
  final Timestamp _requestTime;
  final double _latitude;
  final double _longitude;

  ItemRequest({
    required DocumentReference docRef,
    required String ownerID,
    required String applicantID,
    required String itemID,
    required RequestStatus status,
    required DateTimeRange time,
    required ItemExtensionRequest? extensionRequest,
    required int price,
    required Timestamp requestTime,
    required double latitude,
    required double longitude,
  })  : _docRef = docRef,
        _ownerID = ownerID,
        _applicantID = applicantID,
        _itemID = itemID,
        _status = status,
        _time = time,
        _extensionRequest = extensionRequest,
        _price = price,
        _requestTime = requestTime,
        _latitude = latitude,
        _longitude = longitude;

  DocumentReference get docRef => _docRef;

  String get ownerID => _ownerID;

  String get applicantID => _applicantID;

  String get itemID => _itemID;

  RequestStatus get status => _status;

  DateTimeRange get time => _time;

  ItemExtensionRequest? get extensionRequest => _extensionRequest;

  int get price => _price;

  Timestamp get requestTime => _requestTime;

  double get latitude => _latitude;

  double get longitude => _longitude;

  GeoPoint get geoPoint => GeoPoint(latitude, longitude);

  // just for active rentals
  double? getActiveRentProgressTime() {
    DateTime now = DateTime.now();
    int totalTimeInDays = _time.duration.inDays + 1;
    int daysPassed = now.difference(_time.start).inDays + 1;
    return (_time.start.isBefore(now) && _time.end.isAfter(now)) ? daysPassed / totalTimeInDays : null;
  }

  factory ItemRequest.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Timestamp start = data['time']['start'] as Timestamp;
    Timestamp end = data['time']['end'] as Timestamp;

    return ItemRequest(
      docRef: doc.reference,
      ownerID: data['ownerID'],
      applicantID: data['applicantID'],
      itemID: data['itemID'],
      status: getRequestStatus(data['status']),
      time: DateTimeRange(start: start.toDate(), end: end.toDate()),
      extensionRequest:
          data['extensionRequest'] != null ? ItemExtensionRequest.fromMap(data['extensionRequest']) : null,
      price: data['price'],
      requestTime: data['requestTime'],
      latitude: data['latitude'],
      longitude: data['longitude'],
    );
  }
}
