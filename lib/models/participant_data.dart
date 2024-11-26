import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantData {
  final String _uid;
  final int _unreadMessages;
  final DateTime _lastMessageSeenTime;
  final bool _typing;

  ParticipantData({required String uid, required int unreadMessages, required DateTime lastMessageSeenTime, required bool typing})
      : _uid = uid,
        _unreadMessages = unreadMessages,
        _lastMessageSeenTime = lastMessageSeenTime,
        _typing = typing;

  String get uid => _uid;

  int get unreadMessages => _unreadMessages;

  DateTime get lastMessageSeenTime => _lastMessageSeenTime;

  bool get typing => _typing;

  factory ParticipantData.fromMap(Map<String, dynamic> map) {
    return ParticipantData(
        uid: map['uid'],
        unreadMessages: map['unreadMessages'],
        lastMessageSeenTime: (map['lastMessageSeenTime'] as Timestamp).toDate(),
        typing: map['typing']);
  }
}
