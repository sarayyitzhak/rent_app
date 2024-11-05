import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';

class UserDetails {
  late DocumentReference _userReference;
  late String _name;
  late String _email;
  late int _phoneNumber;
  late List _items;
  late List _wishlist;
  late List _chats;
  String? _token;

  UserDetails({
    required DocumentReference userReference,
    required String name,
    required String email,
    required int phoneNumber,
    required List items,
    required List wishlist,
    required List chats,
    String? token,
  })  : _userReference = userReference,
        _name = name,
        _email = email,
        _phoneNumber = phoneNumber,
        _items = items,
        _wishlist = wishlist,
        _chats = chats,
        _token = token;

  DocumentReference get userReference => _userReference;
  String get name => _name;
  String get email => _email;
  int get phoneNumber => _phoneNumber;
  List get items => _items;
  List get wishlist => _wishlist;
  List get chats => _chats;
  String? get token => _token;

  set name(String value) => _name = value;
  set phoneNumber(int value) => _phoneNumber = value;
  set items(List value) => _items = value;
  set wishlist(List value) => _wishlist = value;
  set chats(List value) => _chats = value;
  set token(String? value) => _token = value;

  // Convert to Map
  Map<String, dynamic> userAsMap() {
    return {
      'fullName': _name,
      'email': _email,
      'phoneNumber': _phoneNumber,
      'items': _items,
      'wishlist': _wishlist,
      'chats': _chats,
      'token': _token,
    };
  }
}

UserDetails mapAsUser(Map<String, dynamic> map){
  final firestore = FirebaseFirestore.instance;
  DocumentReference userReference = firestore.collection('users').doc(userUid);
  return UserDetails(userReference: userReference, name: map['fullName'], email: map['email'], phoneNumber: map['phoneNumber'], items: map['items'], wishlist: map['wishlist'], chats: map['chats'], token: map['token']);
}
