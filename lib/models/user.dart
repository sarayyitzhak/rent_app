import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';

class UserDetails {
  late DocumentReference _userReference;
  late String _name;
  late String _email;
  late int _phoneNumber;
  String? _token;

  UserDetails({
    required DocumentReference userReference,
    required String name,
    required String email,
    required int phoneNumber,
    String? token,
  })  : _userReference = userReference,
        _name = name,
        _email = email,
        _phoneNumber = phoneNumber,
        _token = token;

  DocumentReference get userReference => _userReference;
  String get name => _name;
  String get email => _email;
  int get phoneNumber => _phoneNumber;
  String? get token => _token;

  set name(String value) => _name = value;
  set phoneNumber(int value) => _phoneNumber = value;
  set token(String? value) => _token = value;

  // Convert to Map
  Map<String, dynamic> userAsMap() {
    return {
      'fullName': _name,
      'email': _email,
      'phoneNumber': _phoneNumber,
      'token': _token,
    };
  }
}

UserDetails mapAsUser(Map<String, dynamic> map){
  final firestore = FirebaseFirestore.instance;
  DocumentReference userReference = firestore.collection('users').doc(userUid);
  return UserDetails(userReference: userReference, name: map['fullName'], email: map['email'], phoneNumber: map['phoneNumber'], token: map['token']);
}
