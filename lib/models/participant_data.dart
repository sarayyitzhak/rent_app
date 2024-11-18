import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantData {
  final String _uid;
  final int _unreadMessages;
  final DateTime _lastMessageSeenTime;

  ParticipantData({required String uid, required int unreadMessages, required DateTime lastMessageSeenTime})
      : _uid = uid,
        _unreadMessages = unreadMessages,
        _lastMessageSeenTime = lastMessageSeenTime;

  String get uid => _uid;

  int get unreadMessages => _unreadMessages;

  DateTime get lastMessageSeenTime => _lastMessageSeenTime;

  factory ParticipantData.fromMap(Map<String, dynamic> map) {
    return ParticipantData(
        uid: map['uid'],
        unreadMessages: map['unreadMessages'],
        lastMessageSeenTime: (map['lastMessageSeenTime'] as Timestamp).toDate());
  }
}
