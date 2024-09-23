import 'package:rent_app/db/messageDB.dart';
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