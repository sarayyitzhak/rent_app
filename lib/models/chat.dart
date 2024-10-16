
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/message.dart';

class Chat{
  final DocumentReference _cloudKey;
  final List<DocumentReference> _participants;
  Message? lastMessage;
  late String? otherParticipantName;
  late String? otherParticipantToken;
  Chat({required DocumentReference cloudKey, required List<DocumentReference> participants, Message? lastMessage, String? otherParticipantName, String? otherParticipantToken}) : _cloudKey = cloudKey, _participants = participants, lastMessage = lastMessage, otherParticipantName = otherParticipantName, otherParticipantToken = otherParticipantToken;

  DocumentReference get cloudKey => _cloudKey;
  List<DocumentReference> get participants => _participants;


}

