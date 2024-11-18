import 'package:cloud_firestore/cloud_firestore.dart';

class UserReview {
  final DocumentReference _docRef;
  final String _userID;
  final int? _overallRate;
  final int? _availabilityLevel;
  final int? _punctualityLevel;
  final String _text;
  final DateTime _createdAt;

  UserReview({
    required DocumentReference docRef,
    required String userID,
    int? overallRate,
    int? availabilityLevel,
    int? punctualityLevel,
    required String text,
    required DateTime createdAt,
  })  : _docRef = docRef,
        _userID = userID,
        _overallRate = overallRate,
        _availabilityLevel = availabilityLevel,
        _punctualityLevel = punctualityLevel,
        _text = text,
        _createdAt = createdAt;

  factory UserReview.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserReview(
        docRef: doc.reference,
        userID: data['userID'],
        overallRate: data['overallRate'],
        availabilityLevel: data['availabilityLevel'],
        punctualityLevel: data['punctualityLevel'],
        text: data['text'],
        createdAt: data['createdAt'].toDate()
    );
  }

  DocumentReference get docRef => _docRef;

  String get userID => _userID;

  int? get overallRate => _overallRate;

  String get text => _text;

  DateTime get createdAt => _createdAt;

  int? get punctualityLevel => _punctualityLevel;

  int? get availabilityLevel => _availabilityLevel;
}
