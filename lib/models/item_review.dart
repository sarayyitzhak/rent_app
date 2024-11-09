import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/condition.dart';

class ItemReview {
  final DocumentReference _docRef;
  final String _userID;
  final int? _overallRate;
  final int? _valueForPrice;
  final int? _compatibility;
  final String? _text;
  final Condition? _condition;
  final DateTime _createdAt;

  ItemReview({
    required DocumentReference docRef,
    required String userID,
    int? overallRate,
    int? valueForPrice,
    int? compatibility,
    String? text,
    Condition? condition,
    required DateTime createdAt,
  })  : _docRef = docRef,
        _userID = userID,
        _overallRate = overallRate,
        _valueForPrice = valueForPrice,
        _compatibility = compatibility,
        _text = text,
        _condition = condition,
        _createdAt = createdAt;

  factory ItemReview.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ItemReview(
        docRef: doc.reference,
        userID: data['userID'],
        overallRate: data['overallRate'],
        valueForPrice: data['valueForPrice'],
        compatibility: data['compatibility'],
        text: data['text'],
        condition: data['condition'] != null ? Condition.values[data['condition']] : null,
        createdAt: data['createdAt'].toDate()
    );
  }

  DocumentReference get docRef => _docRef;

  String get userID => _userID;

  int? get overallRate => _overallRate;

  int? get valueForPrice => _valueForPrice;

  int? get compatibility => _compatibility;

  String? get text => _text;

  Condition? get condition => _condition;

  DateTime get createdAt => _createdAt;
}
