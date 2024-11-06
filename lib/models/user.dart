import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetails {
  late DocumentReference _docRef;
  late String _name;
  late int _phoneNumber;
  String? _token;

  UserDetails({
    required DocumentReference docRef,
    required String name,
    required int phoneNumber,
    String? token,
  })  : _docRef = docRef,
        _name = name,
        _phoneNumber = phoneNumber,
        _token = token;

  DocumentReference get docRef => _docRef;

  String get name => _name;

  int get phoneNumber => _phoneNumber;

  String? get token => _token;

  set name(String value) => _name = value;

  set phoneNumber(int value) => _phoneNumber = value;

  set token(String? value) => _token = value;

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
    );
  }
}
