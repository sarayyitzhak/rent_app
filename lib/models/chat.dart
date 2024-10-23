
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/participant_data.dart';

class Chat{
  final DocumentReference _docRef;
  final DateTime _lastMessageSentAt;
  final Map<String, ParticipantData> _participants;

  Chat({required DocumentReference docRef, required DateTime lastMessageSentAt, required Map<String, ParticipantData> participants}) : _docRef = docRef, _lastMessageSentAt = lastMessageSentAt, _participants = participants;

  DocumentReference get docRef => _docRef;

  DateTime get lastMessageSentAt => _lastMessageSentAt;

  Map<String, ParticipantData> get participants => _participants;

  factory Chat.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Chat(
      docRef: doc.reference,
      lastMessageSentAt: (data['lastMessageSentAt'] as Timestamp).toDate(),
      participants: (data['participants'] as Map<String, dynamic>).map((key, value) => MapEntry(key, ParticipantData.fromMap(value)))
    );
  }
}

