import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';

class IsarModel extends ChangeNotifier {
  late final Isar _isar;

  IsarModel(this._isar);
  Isar get isar => _isar;

// Your methods to interact with Isar go here
}