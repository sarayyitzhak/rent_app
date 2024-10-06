
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/message.dart';

class Chat{
  DocumentReference cloudKey;
  List<DocumentReference> participants;
  Message? lastMessage;
  String? otherParticipantName;
  String? otherParticipantToken;
  // List messages;
  // Chat({required this.person1, required this.person2, required this.messages});
  Chat({required this.participants, required this.cloudKey, this.lastMessage, this.otherParticipantName, this.otherParticipantToken});
}

