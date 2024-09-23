import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';

import 'chatDB.dart';
part 'messageDB.g.dart';

@collection
  class Message{
    late Id id = Isar.autoIncrement;
    late int sender;
    late String text;
    late DateTime sentAt;
    late bool read;
    late String senderName;
    @Backlink(to: 'messages')
    final chat = IsarLink<Chat>();
    @ignore
    DocumentReference? senderRef;
    @ignore
    DocumentReference? messRef;
    // Message({required this.sender, required this.text, required this.read, required this.sentAt, this.senderRef});
  }