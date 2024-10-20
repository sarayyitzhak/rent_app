import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/models/request_status.dart';
import 'package:rent_app/models/user.dart';
import 'address_info.dart';
import 'item.dart';

class ItemRequest {
  final String? _cloudKey;
  final String _ownerID;
  final String _applicantID;
  final String _itemID;
  RequestStatus _status;
  final DateTimeRange _time;
  final int _finalPrice;
  final AddressInfo _pickUpLocation;
  final Timestamp _requestTime;

  Item? _item;
  UserDetails? _owner;
  UserDetails? _applicant;

  ItemRequest({
    String? cloudKey,
    required String ownerID,
    required String applicantID,
    required String itemID,
    required RequestStatus status,
    required DateTimeRange time,
    required int finalPrice,
    required AddressInfo pickUpLocation,
    required Timestamp requestTime,
    Item? item,
    UserDetails? owner,
    UserDetails? applicant,
  })  : _cloudKey = cloudKey,
        _ownerID = ownerID,
        _applicantID = applicantID,
        _itemID = itemID,
        _status = status,
        _time = time,
        _finalPrice = finalPrice,
        _pickUpLocation = pickUpLocation,
        _requestTime = requestTime,
        _item = item,
        _owner = owner,
        _applicant = applicant;

  String? get cloudKey => _cloudKey;
  String get ownerID => _ownerID;
  String get applicantID => _applicantID;
  String get itemID => _itemID;
  RequestStatus get status => _status;
  DateTimeRange get time => _time;
  int get finalPrice => _finalPrice;
  AddressInfo get pickUpLocation => _pickUpLocation;
  Timestamp get requestTime => _requestTime;
  Item? get item => _item;
  UserDetails? get owner => _owner;
  UserDetails? get applicant => _applicant;

  set status(RequestStatus newStatus) => _status = newStatus;
  set item(Item? newItem) => _item = newItem;
  set owner(UserDetails? newOwner) => _owner = newOwner;
  set applicant(UserDetails? newApplicant) => _applicant = newApplicant;

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
}

ItemRequest mapToItemRequest(Map<String, dynamic> map, String cloudKey) {
  Timestamp start = map['time']['start'];
  Timestamp end = map['time']['end'];
  DateTimeRange time = DateTimeRange(start: start.toDate(), end: end.toDate());
  return ItemRequest(
      cloudKey: cloudKey,
      ownerID: map['ownerID'],
      applicantID: map['applicantID'],
      itemID: map['itemID'],
      status: getRequestStatus(map['status']),
      time: time,
      finalPrice: map['finalPrice'],
      pickUpLocation: mapToAddressInfo(map['pickUpLocation']),
      requestTime: map['requestTime']);
}
