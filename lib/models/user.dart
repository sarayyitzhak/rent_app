import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_app/services/user_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';

class UserDetails{
  DocumentReference userReference;
  // String? userUid;
  String name;
  String email;
  int phoneNumber;
  // Timestamp dateOfBirth;
  List items;
  List wishlist;
  List chats;
  UserDetails({required this.userReference, required this.name, required this.email, required this.phoneNumber, required this.items, required this.wishlist, required this.chats});


  Map<String, dynamic> userAsMap(){
    return {
      'fullName': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'items': items,
      'wishlist': wishlist,
      'chats': chats
    };
  }
}

UserDetails mapAsUser(Map<String, dynamic> map){
  final _firestore = FirebaseFirestore.instance;
  DocumentReference userReference = _firestore.collection('users').doc(userUid);
  return UserDetails(userReference: userReference, name: map['fullName'], email: map['email'], phoneNumber: map['phoneNumber'], items: map['items'], wishlist: map['wishlist'], chats: map['chats']);
}

Future<UserDetails> getUserDetailsByUid(String uid) async {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  UserServices userServices = UserServices(_auth, _firestore);
  Map<String, dynamic> userData = await userServices.getUserData(uid);
  UserDetails u = mapAsUser(userData);
  return u;
}