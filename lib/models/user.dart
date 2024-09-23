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
  List seen;
  List chats;
  String? token;
  UserDetails({required this.userReference, required this.name, required this.email, required this.phoneNumber, required this.items, required this.wishlist, required this.seen, required this.chats, this.token});


  Map<String, dynamic> userAsMap(){
    return {
      'fullName': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'items': items,
      'wishlist': wishlist,
      'seen': seen,
      'chats': chats,
      'token': token
    };
  }
}

UserDetails mapAsUser(Map<String, dynamic> map){
  final firestore = FirebaseFirestore.instance;
  DocumentReference userReference = firestore.collection('users').doc(userUid);
  return UserDetails(userReference: userReference, name: map['fullName'], email: map['email'], phoneNumber: map['phoneNumber'], items: map['items'], wishlist: map['wishlist'], seen: map['seen'], chats: map['chats'], token: map['token']);
}

Future<UserDetails> getUserDetailsByUid(String uid) async {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  UserServices userServices = UserServices(auth, firestore);
  Map<String, dynamic> userData = await userServices.getUserData(uid);
  UserDetails u = mapAsUser(userData);
  return u;
}