import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/models/request_status.dart';
import 'package:rent_app/models/user.dart';
import 'address_info.dart';
import 'item.dart';

class ItemRequest {

  final DocumentReference _docRef;
  final String _ownerID;
  final String _applicantID;
  final String _itemID;
  final RequestStatus _status;
  final DateTimeRange _time;
  final int _finalPrice;
  final AddressInfo _pickUpLocation;
  final Timestamp _requestTime;

  ItemRequest({
    required DocumentReference docRef,
    required String ownerID,
    required String applicantID,
    required String itemID,
    required RequestStatus status,
    required DateTimeRange time,
    required int finalPrice,
    required AddressInfo pickUpLocation,
    required Timestamp requestTime,
  })  : _docRef = docRef,
        _ownerID = ownerID,
        _applicantID = applicantID,
        _itemID = itemID,
        _status = status,
        _time = time,
        _finalPrice = finalPrice,
        _pickUpLocation = pickUpLocation,
        _requestTime = requestTime;

  DocumentReference get docRef => _docRef;
  String get ownerID => _ownerID;
  String get applicantID => _applicantID;
  String get itemID => _itemID;
  RequestStatus get status => _status;
  DateTimeRange get time => _time;
  int get finalPrice => _finalPrice;
  AddressInfo get pickUpLocation => _pickUpLocation;
  Timestamp get requestTime => _requestTime;

  Map<String, dynamic> toMap() {
    return {
      'ownerID': _ownerID,
      'applicantID': _applicantID,
      'itemID': _itemID,
      'status': _status.index,
      'time': {'start': _time.start, 'end': _time.end},
      'finalPrice': _finalPrice,
      'pickUpLocation': _pickUpLocation.toMap(),
      'requestTime': _requestTime
    };
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
      finalPrice: data['finalPrice'],
      pickUpLocation: mapToAddressInfo(data['pickUpLocation']),
      requestTime: data['requestTime']
    );
  }
}
