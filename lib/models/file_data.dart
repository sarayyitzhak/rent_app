import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class FileData {
  final String name;
  final String extension;
  final String fullPath;
  final bool exists;
  final Uint8List data;
  final Reference? fileRef;

  FileData(Uint8List? fileData, this.name, this.extension, [this.fullPath = '', this.fileRef])
      : data = fileData ?? Uint8List.fromList([]),
        exists = fileData != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FileData && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  get fullName => '$name.$extension';

  factory FileData.fromDataAndReference(Uint8List? fileData, Reference reference) {
    String name = reference.name.substring(0, reference.name.lastIndexOf('.'));
    String extension = reference.name.contains('.') ? reference.name.split('.').last : '';

    return FileData(fileData, name, extension, reference.fullPath, reference);
  }

  factory FileData.fromDataAndName(Uint8List? fileData, String name, [String extension = 'jpg']) {
    return FileData(fileData, name, extension);
  }
}
