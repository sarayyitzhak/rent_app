import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/address_info.dart';
import 'category.dart';
import 'condition.dart';

class Item {
  final DocumentReference _docRef;
  final String _contactUserID;
  final String _imageRef;
  final String _title;
  final int _price;
  final AddressInfo _location;
  final String _description;
  final Condition _condition;
  final List<ItemCategory> _categories;
  final DateTime _createdAt;
  final int _favoriteCount;
  final int _seenCount;
  final int? _reviewCount;
  final int? _rateSum;

  Item({
    required DocumentReference docRef,
    required String contactUserID,
    required String imageRef,
    required String title,
    required int price,
    required AddressInfo location,
    required String description,
    required Condition condition,
    required List<ItemCategory> categories,
    required DateTime createdAt,
    required int favoriteCount,
    required int seenCount,
    int? reviewCount,
    int? rateSum,
  })  : _docRef = docRef,
        _contactUserID = contactUserID,
        _imageRef = imageRef,
        _title = title,
        _price = price,
        _location = location,
        _description = description,
        _condition = condition,
        _categories = categories,
        _createdAt = createdAt,
        _favoriteCount = favoriteCount,
        _seenCount = seenCount,
        _reviewCount = reviewCount,
        _rateSum = rateSum;

  DocumentReference get docRef => _docRef;

  String get contactUserID => _contactUserID;

  String get imageRef => _imageRef;

  String get title => _title;

  int get price => _price;

  AddressInfo get location => _location;

  String get description => _description;

  Condition get condition => _condition;

  List<ItemCategory> get categories => _categories;

  DateTime get createdAt => _createdAt;

  int get favoriteCount => _favoriteCount;

  int get seenCount => _seenCount;

  int? get reviewCount => _reviewCount;

  int? get rateSum => _rateSum;

  double? getRate() {
    return (reviewCount != null && reviewCount != 0) ? (rateSum! / reviewCount!) : null;
  }

  factory Item.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Item(
      docRef: doc.reference,
      contactUserID: data['contactUserID'],
      imageRef: data['imageRef'],
      title: data['title'],
      price: data['price'],
      location: AddressInfo.fromMap(data['location']),
      description: data['description'],
      condition: Condition.values[data['condition']],
      categories: (data['categories'] as List<dynamic>).map((idx) => ItemCategory.values[idx]).toList(),
      createdAt: data['createdAt'].toDate(),
      favoriteCount: data['favoriteCount'],
      seenCount: data['seenCount'],
      reviewCount: data['reviewCount'],
      rateSum: data['rateSum']
    );
  }
}
