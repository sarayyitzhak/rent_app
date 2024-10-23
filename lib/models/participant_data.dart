
import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantData {
  final int _index;
  final DateTime _lastMessageSeenTime;

  ParticipantData({required int index, required DateTime lastMessageSeenTime}) : _index = index, _lastMessageSeenTime = lastMessageSeenTime;

  int get index => _index;

  DateTime get lastMessageSeenTime => _lastMessageSeenTime;

  factory ParticipantData.fromMap(Map<String, dynamic> map) {
    return ParticipantData(
      index: map['index'] as int,
      lastMessageSeenTime: (map['lastMessageSeenTime'] as Timestamp).toDate()
    );
  }
}