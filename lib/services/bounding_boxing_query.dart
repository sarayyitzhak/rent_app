import 'package:rent_app/models/item.dart';
import 'package:rent_app/services/query_batch.dart';

class BoundingBoxingQuery extends QueryBatch<Item> {
  static const int kMaxDistance = 20000;  /* in meters */
  static const int kDistanceStep = 500;   /* in meters */

  final int _currentDistance;

  BoundingBoxingQuery(super.list, super.hasMore, super.lastDoc, this._currentDistance);

  int get currentDistance => _currentDistance;

  factory BoundingBoxingQuery.empty() {
    return BoundingBoxingQuery([], true, null, kDistanceStep);
  }
}
