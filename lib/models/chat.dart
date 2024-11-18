import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/participant_data.dart';

class Chat {
  final DocumentReference _docRef;
  final DateTime _lastMessageTime;
  final dynamic _lastMessageContent;
  final ParticipantData _participantInfo0;
  final ParticipantData _participantInfo1;

  Chat(
      {required DocumentReference docRef,
      required DateTime lastMessageTime,
      required dynamic lastMessageContent,
      required ParticipantData participantInfo0,
      required ParticipantData participantInfo1})
      : _docRef = docRef,
        _lastMessageTime = lastMessageTime,
        _lastMessageContent = lastMessageContent,
        _participantInfo0 = participantInfo0,
        _participantInfo1 = participantInfo1;

  DocumentReference get docRef => _docRef;

  DateTime get lastMessageTime => _lastMessageTime;

  dynamic get lastMessageContent => _lastMessageContent;

  ParticipantData get participantInfo0 => _participantInfo0;

  ParticipantData get participantInfo1 => _participantInfo1;

  factory Chat.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Chat(
        docRef: doc.reference,
        lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
        lastMessageContent: data['lastMessageContent'],
        participantInfo0: ParticipantData.fromMap(data['participantInfo0'] as Map<String, dynamic>),
        participantInfo1: ParticipantData.fromMap(data['participantInfo1'] as Map<String, dynamic>));
  }
}
