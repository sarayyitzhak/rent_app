import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetails {
  late DocumentReference _docRef;
  late String _name;
  late int _phoneNumber;
  final DateTime _lastSeenTime;
  final bool _online;
  String? _token;
  int? _overallRateCount;
  int? _overallRateSum;
  String? _photoID;
  bool _showPhoneNumber;

  UserDetails({
    required DocumentReference docRef,
    required String name,
    required int phoneNumber,
    required DateTime lastSeenTime,
    required bool online,
    String? token,
    int? overallRateCount,
    int? overallRateSum,
    String? photoID,
    required bool showPhoneNumber,
  })  : _docRef = docRef,
        _name = name,
        _phoneNumber = phoneNumber,
        _lastSeenTime = lastSeenTime,
        _online = online,
        _token = token,
        _overallRateCount = overallRateCount,
        _overallRateSum = overallRateSum,
        _photoID = photoID,
        _showPhoneNumber = showPhoneNumber;

  DocumentReference get docRef => _docRef;

  String get name => _name;

  int get phoneNumber => _phoneNumber;

  DateTime get lastSeenTime => _lastSeenTime;

  bool get online => _online;

  String? get token => _token;

  int? get overallRateCount => _overallRateCount;

  int? get overallRateSum => _overallRateSum;

  String? get photoID => _photoID;

  bool get showPhoneNumber => _showPhoneNumber;

  set name(String value) => _name = value;

  set phoneNumber(int value) => _phoneNumber = value;

  set token(String? value) => _token = value;

  set photoID(String? value) {
    _photoID = value;
  }

  set showPhoneNumber(bool value) {
    _showPhoneNumber = value;
  }

  double? getRate() {
    return (overallRateSum != null && overallRateCount != 0)
        ? (overallRateSum! / overallRateCount!)
        : null;
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
    final dynamic rawPhone = data['phoneNumber'];
    final int parsedPhone = rawPhone is int
        ? rawPhone
        : int.tryParse(rawPhone?.toString() ?? '') ?? 0;

    return UserDetails(
        docRef: doc.reference,
        name: (data['fullName'] ?? '') as String,
        phoneNumber: parsedPhone,
        lastSeenTime:
            (data['lastSeenTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
        online: (data['online'] as bool?) ?? true,
        token: data['token'],
        overallRateCount: data['overallRateCount'],
        overallRateSum: data['overallRateSum'],
        photoID: data['photoID'],
        showPhoneNumber: (data['showPhoneNumber'] as bool?) ?? false);
  }
}
