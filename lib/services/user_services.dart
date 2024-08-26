import 'package:firebase_auth/firebase_auth.dart';

class UserServices{
  final _auth;
  final _firestore;
  UserServices(this._auth, this._firestore);

  Future<dynamic> getUserData(String userUid) async{
    return await _firestore.collection('users').doc(userUid).get();
  }

  User? getCurrentUser() {
    try {
      return _auth.currentUser;
    } catch (e) {
      print(e);
    }
    return null;
  }
}