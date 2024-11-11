import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/address_info.dart';
import 'category.dart';
import 'condition.dart';

class Item {
  final DocumentReference _docRef;
  final String _contactUserID;
  final String _mainImage;
  final List<String> _images;
  final String _title;
  final int _price;
  final AddressInfo _location;
  final String _description;
  final Condition _condition;
  final List<ItemCategory> _categories;
  final DateTime _createdAt;
  final int _favoriteCount;
  final int _seenCount;
  final int? _overallRateCount;
  final int? _overallRateSum;

  Item({
    required DocumentReference docRef,
    required String contactUserID,
    required String mainImage,
    required List<String> images,
    required String title,
    required int price,
    required AddressInfo location,
    required String description,
    required Condition condition,
    required List<ItemCategory> categories,
    required DateTime createdAt,
    required int favoriteCount,
    required int seenCount,
    int? overallRateCount,
    int? overallRateSum,
  })  : _docRef = docRef,
        _contactUserID = contactUserID,
        _mainImage = mainImage,
        _images = images,
        _title = title,
        _price = price,
        _location = location,
        _description = description,
        _condition = condition,
        _categories = categories,
        _createdAt = createdAt,
        _favoriteCount = favoriteCount,
        _seenCount = seenCount,
        _overallRateCount = overallRateCount,
        _overallRateSum = overallRateSum;

  DocumentReference get docRef => _docRef;

  String get contactUserID => _contactUserID;

  String get mainImage => _mainImage;

  List<String> get images => _images;

  String get title => _title;

  int get price => _price;

  AddressInfo get location => _location;

  String get description => _description;

  Condition get condition => _condition;

  List<ItemCategory> get categories => _categories;

  DateTime get createdAt => _createdAt;

  int get favoriteCount => _favoriteCount;

  int get seenCount => _seenCount;

  int? get overallRateCount => _overallRateCount;

  int? get overallRateSum => _overallRateSum;

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
      location: AddressInfo.fromMap(data['location']),
      description: data['description'],
      condition: Condition.values[data['condition']],
      categories: (data['categories'] as List<dynamic>).map((idx) => ItemCategory.values[idx]).toList(),
      createdAt: data['createdAt'].toDate(),
      favoriteCount: data['favoriteCount'],
      seenCount: data['seenCount'],
      overallRateCount: data['overallRateCount'],
      overallRateSum: data['overallRateSum']
    );
  }
}
