import 'package:cloud_firestore/cloud_firestore.dart';
import 'category.dart';
import 'condition.dart';

class Item {
  final DocumentReference _docRef;
  final String _contactUserID;
  final String _mainImage;
  final List<String> _images;
  final String _title;
  final int _price;
  final String _description;
  final Condition _condition;
  final List<ItemCategory> _categories;
  final DateTime _createdAt;
  final int _favoriteCount;
  final int _seenCount;
  final int? _overallRateCount;
  final int? _overallRateSum;
  final double _latitude;
  final double _longitude;

  Item({
    required DocumentReference docRef,
    required String contactUserID,
    required String mainImage,
    required List<String> images,
    required String title,
    required int price,
    required String description,
    required Condition condition,
    required List<ItemCategory> categories,
    required DateTime createdAt,
    required int favoriteCount,
    required int seenCount,
    int? overallRateCount,
    int? overallRateSum,
    required double latitude,
    required double longitude,
  })  : _docRef = docRef,
        _contactUserID = contactUserID,
        _mainImage = mainImage,
        _images = images,
        _title = title,
        _price = price,
        _description = description,
        _condition = condition,
        _categories = categories,
        _createdAt = createdAt,
        _favoriteCount = favoriteCount,
        _seenCount = seenCount,
        _overallRateCount = overallRateCount,
        _overallRateSum = overallRateSum,
        _latitude = latitude,
        _longitude = longitude;

  DocumentReference get docRef => _docRef;

  String get contactUserID => _contactUserID;

  String get mainImage => _mainImage;

  List<String> get images => _images;

  String get title => _title;

  int get price => _price;

  String get description => _description;

  Condition get condition => _condition;

  List<ItemCategory> get categories => _categories;

  DateTime get createdAt => _createdAt;

  int get favoriteCount => _favoriteCount;

  int get seenCount => _seenCount;

  int? get overallRateCount => _overallRateCount;

  int? get overallRateSum => _overallRateSum;

  double get latitude => _latitude;

  double get longitude => _longitude;

  GeoPoint get geoPoint => GeoPoint(latitude, longitude);

  double? getRate() {
    return (overallRateSum != null && overallRateCount != 0) ? (overallRateSum! / overallRateCount!) : null;
  }

  factory Item.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Item(
      docRef: doc.reference,
      contactUserID: data['contactUserID'],
      mainImage: data['mainImage'],
      images: data['images']?.cast<String>() ?? [],
      title: data['title'],
      price: data['price'],
      description: data['description'],
      condition: Condition.values[data['condition']],
      categories: (data['categories'] as List<dynamic>).map((idx) => ItemCategory.values[idx]).toList(),
      createdAt: data['createdAt'].toDate(),
      favoriteCount: data['favoriteCount'],
      seenCount: data['seenCount'],
      overallRateCount: data['overallRateCount'],
      overallRateSum: data['overallRateSum'],
      latitude: data['latitude'],
      longitude: data['longitude'],
    );
  }
}
