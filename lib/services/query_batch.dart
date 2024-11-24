
import 'package:cloud_firestore/cloud_firestore.dart';

class QueryBatch<T> {
  final List<T> _list;
  final bool _hasMore;
  final DocumentSnapshot? _lastDoc;

  QueryBatch(this._list, this._hasMore, this._lastDoc);

  bool get hasMore => _hasMore;

  List<T> get list => _list;

  int get size => _list.length;

  DocumentSnapshot? get lastDoc => _lastDoc;

  factory QueryBatch.empty() {
    return QueryBatch([], true, null);
  }
}