

import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  late DocumentReference cloudKey;
  late int sender;
  late String text;
  late DateTime sentAt;
  late bool read;
  late String senderName;
  DocumentReference? senderRef;
  DocumentReference? messRef;
  Message({required this.sender, required this.text, required this.read, required this.sentAt, this.senderRef});

  String sentAtAsString(){
    String minute = sentAt.minute.toString();
    if(sentAt.minute < 10){
      minute = '0$minute';
    }
    return '${sentAt.hour}:$minute';
  }
}