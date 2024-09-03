import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/db/messageDB.dart';
import 'package:rent_app/services/address_services.dart';
import 'package:rent_app/models/category.dart';
import 'package:rent_app/models/condition.dart';
import 'package:isar/isar.dart';
part 'chatDB.g.dart';

@collection
class Chat{
  Id? id = Isar.autoIncrement;
  List<String>? participants;
  final messages = IsarLinks<Message>();
  String? cloudKey;
  // Chat({this.participants});
}