

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/messageType.dart';

class Message {
  late DocumentReference _cloudKey;
  late int _sender;
  late String _text;
  late String? _fileRef;
  late DateTime _sentAt;
  late bool _read;
  late String _senderName;
  late MessageType _type;
  DocumentReference? _senderRef;

  Message({
    required int sender,
    required String text,
    String? fileRef,
    required bool read,
    required DateTime sentAt,
    required MessageType type,
    DocumentReference? senderRef,
  })  : _sender = sender,
        _text = text,
        _fileRef = fileRef,
        _read = read,
        _sentAt = sentAt,
        _type = type,
        _senderRef = senderRef;

  DocumentReference get cloudKey => _cloudKey;
  int get sender => _sender;
  String get text => _text;
  String? get fileRef => _fileRef;
  DateTime get sentAt => _sentAt;
  bool get read => _read;
  String get senderName => _senderName;
  MessageType get type => _type;
  DocumentReference? get senderRef => _senderRef;

  set fileRef(String? value) => _fileRef = value;
  set read(bool value) => _read = value;
  set senderRef(DocumentReference? value) => _senderRef = value;

  String sentAtAsString() {
    String minute = _sentAt.minute.toString().padLeft(2, '0');
    return '${_sentAt.hour}:$minute';
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'sender': _sender,
      'text': _text,
      'sentAt': _sentAt,
      'read': _read,
      'type': _type.index,
    };
    if (_fileRef != null) {
      map['fileRef'] = _fileRef;
    }
    return map;
  }
}

Message mapAsMessage(Map<String, dynamic> map){
  Message message = Message(read: map['read'], sender: map['sender'], sentAt: map['sentAt'].toDate(), text: map['text'], type: numToMessageType(map['type']));
  if(map.containsKey('fileRef')){
    message.fileRef = map['fileRef'];
  }
  return message;
}