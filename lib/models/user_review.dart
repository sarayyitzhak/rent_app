import 'package:cloud_firestore/cloud_firestore.dart';

class UserReview {
  final DocumentReference _docRef;
  final String _userID;
  final int? _overallRate;
  final int? _serviceLevel;
  final String _text;
  final DateTime _createdAt;

  UserReview({
    required DocumentReference docRef,
    required String userID,
    int? overallRate,
    int? serviceLevel,
    required String text,
    required DateTime createdAt,
  })  : _docRef = docRef,
        _userID = userID,
        _overallRate = overallRate,
        _serviceLevel = serviceLevel,
        _text = text,
        _createdAt = createdAt;

  factory UserReview.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserReview(
        docRef: doc.reference,
        userID: data['userID'],
        overallRate: data['overallRate'],
        serviceLevel: data['serviceLevel'],
        text: data['text'],
        createdAt: data['createdAt'].toDate()
    );
  }

  DocumentReference get docRef => _docRef;

  String get userID => _userID;

  int? get overallRate => _overallRate;

  int? get serviceLevel => _serviceLevel;

  String get text => _text;

  DateTime get createdAt => _createdAt;
}
