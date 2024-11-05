import 'package:cloud_firestore/cloud_firestore.dart';

class ItemReview {
  final DocumentReference _docRef;
  final String _userID;
  final int _rate;
  final String _text;
  final DateTime _createdAt;

  ItemReview({
    required DocumentReference docRef,
    required String userID,
    required int rate,
    required String text,
    required DateTime createdAt,
  })
      : _docRef = docRef,
        _userID = userID,
        _rate = rate,
        _text = text,
        _createdAt = createdAt;

  Map<String, dynamic> toMap() {
    return {
      'userID': _userID,
      'rate': _rate,
      'text': _text,
      'createdAt': _createdAt
    };
  }

  factory ItemReview.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ItemReview(
        docRef: doc.reference,
        userID: doc.reference.id,
        rate: data['rate'],
        text: data['text'],
        createdAt: data['createdAt'].toDate()
    );
  }
}
