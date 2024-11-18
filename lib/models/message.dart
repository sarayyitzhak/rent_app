import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/message_type.dart';

class Message {
  final DocumentReference _docRef;
  final bool _sentBy0;
  final DateTime _sentAt;
  final MessageType _type;
  final String? _text;
  final String? _itemID;

  Message({
    required DocumentReference docRef,
    required bool sentBy0,
    required DateTime sentAt,
    required MessageType type,
    required String? text,
    required String? itemID,
  })  : _docRef = docRef,
        _sentBy0 = sentBy0,
        _sentAt = sentAt,
        _type = type,
        _text = text,
        _itemID = itemID;

  DocumentReference get docRef => _docRef;

  bool get sentBy0 => _sentBy0;

  DateTime get sentAt => _sentAt;

  MessageType get type => _type;

  String? get text => _text;

  String? get itemID => _itemID;

  factory Message.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Message(
        docRef: doc.reference,
        sentBy0: data['sentBy0'],
        sentAt: (data['sentAt'] as Timestamp).toDate(),
        type: numToMessageType(data['type']),
        text: data['text'],
        itemID: data['itemID']);
  }
}
