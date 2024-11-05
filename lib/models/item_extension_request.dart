
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/request_status.dart';

class ItemExtensionRequest {
  final DateTime _toDate;
  final RequestStatus _status;
  final DateTime _requestTime;

  ItemExtensionRequest({required DateTime toDate, required RequestStatus status, required DateTime requestTime}) : _toDate = toDate, _status = status, _requestTime = requestTime;

  DateTime get requestTime => _requestTime;

  RequestStatus get status => _status;

  DateTime get toDate => _toDate;

  factory ItemExtensionRequest.fromMap(Map<String, dynamic> map) {
    return ItemExtensionRequest(
      toDate: (map['toDate'] as Timestamp).toDate(),
      status: getRequestStatus(map['status']),
      requestTime: (map['requestTime'] as Timestamp).toDate()
    );
  }
}