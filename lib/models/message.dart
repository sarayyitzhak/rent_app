

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/messageType.dart';

class Message{
  late DocumentReference cloudKey;
  late int sender;
  late String text;
  late String? fileRef;
  late DateTime sentAt;
  late bool read;
  late String senderName;
  late MessageType type;
  DocumentReference? senderRef;
  Message({required this.sender, required this.text, this.fileRef, required this.read, required this.sentAt, required this.type, this.senderRef});

  String sentAtAsString(){
    String minute = sentAt.minute.toString();
    if(sentAt.minute < 10){
      minute = '0$minute';
    }
    return '${sentAt.hour}:$minute';
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'sender': sender,
      'text': text,
      'sentAt': sentAt,
      'read': read,
      'type': type.index
    };
    if(fileRef != null){
      map['fileRef'] = fileRef;
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