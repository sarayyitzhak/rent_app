import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetails {
  late DocumentReference _docRef;
  late String _name;
  late int _phoneNumber;
  String? _token;
  int? _overallRateCount;
  int? _overallRateSum;

  UserDetails({
    required DocumentReference docRef,
    required String name,
    required int phoneNumber,
    String? token,
    int? overallRateCount,
    int? overallRateSum
  })  : _docRef = docRef,
        _name = name,
        _phoneNumber = phoneNumber,
        _token = token,
        _overallRateCount = overallRateCount,
        _overallRateSum = overallRateSum;

  DocumentReference get docRef => _docRef;

  String get name => _name;

  int get phoneNumber => _phoneNumber;

  String? get token => _token;

  int? get overallRateCount => _overallRateCount;

  int? get overallRateSum => _overallRateSum;

  set name(String value) => _name = value;

  set phoneNumber(int value) => _phoneNumber = value;

  set token(String? value) => _token = value;

  double? getRate() {
    return (overallRateSum != null && overallRateCount != 0) ? (overallRateSum! / overallRateCount!) : null;
  }

  // Convert to Map
  Map<String, dynamic> userAsMap() {
    return {
      'fullName': _name,
      'phoneNumber': _phoneNumber,
      'token': _token,
    };
  }

  factory UserDetails.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserDetails(
      docRef: doc.reference,
      name: data['fullName'],
      phoneNumber: data['phoneNumber'],
      token: data['token'],
      overallRateCount: data['overallRateCount'],
      overallRateSum: data['overallRateSum']
    );
  }

}
