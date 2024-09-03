
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat{
  DocumentReference person1;
  DocumentReference person2;
  // List messages;
  // Chat({required this.person1, required this.person2, required this.messages});
  Chat({required this.person1, required this.person2});
}