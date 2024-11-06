
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/address_info.dart';
import 'category.dart';
import 'condition.dart';

class Item {
  final DocumentReference _itemReference;
  final DocumentReference _contactUser;
  String _imageRef;
  String _title;
  int _price;
  AddressInfo _location;
  String _description;
  Condition _condition;
  List<dynamic> _categories;
  final Timestamp _createdAt;
  int _favoriteCount;
  int _seenCount;
  int? _reviewCount;
  int? _rateSum;

  // Constructor
  Item({
    required DocumentReference itemReference,
    required DocumentReference contactUser,
    required String imageRef,
    required String title,
    required int price,
    required AddressInfo location,
    required String description,
    required Condition condition,
    required List<dynamic> categories,
    required Timestamp createdAt,
    required int favoriteCount,
    required int seenCount,
    int? reviewCount,
    int? rateSum,
  })  : _itemReference = itemReference,
        _contactUser = contactUser,
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

  DocumentReference get itemReference => _itemReference;
  DocumentReference get contactUser => _contactUser;
  String get imageRef => _imageRef;
  String get title => _title;
  int get price => _price;
  AddressInfo get location => _location;
  String get description => _description;
  Condition get condition => _condition;
  List<dynamic> get categories => _categories;

  Timestamp get createdAt => _createdAt;
  int get favoriteCount => _favoriteCount;
  int get seenCount => _seenCount;
  int? get reviewCount => _reviewCount;
  int? get rateSum => _rateSum;

  set imageRef(String value) => _imageRef = value;
  set favoriteCount(int value) => _favoriteCount = value;
  set seenCount(int value) => _seenCount = value;
  set price(int value) => _price = value;
  set location(AddressInfo value) => _location = value;
  set description(String value) => _description = value;
  set title(String value) => _title = value;
  set condition(Condition value) => _condition = value;
  set categories(List<dynamic> value) => _categories = value;
  set reviewCount(int? value) => _reviewCount = value;
  set rateSum(int? value) => _rateSum = value;

  double? getRate(){
    return reviewCount != null ? (rateSum! / reviewCount!) : null;
  }

  Map<String, dynamic> itemToMap() {
    return {
      'contactUser': _contactUser,
      'imageRef': _imageRef,
      'title': _title,
      'price': _price,
      'location': _location.toMap(),
      'description': _description,
      'condition': _condition.idx,
      'categories': _categories.map((c) => c.idx).toList(),
      'createdAt': _createdAt,
      'favoriteCount': _favoriteCount,
      'seenCount': _seenCount,
      'reviewCount': _reviewCount,
      'rateSum': _rateSum
    };
  }
}

Item mapAsItem(Map<String, dynamic> map, DocumentReference itemRef) {
  var categoryTitlesList = map['categories'];
  List<ItemCategory> categoryList = [];
  for (int idx in categoryTitlesList) {
    categoryList.add(getCategoryByIdx(idx));
  }

  Condition condition = getCondFromIdx(map['condition']);
  return Item(
    itemReference: itemRef,
    contactUser: map['contactUser'],
    imageRef: map['imageRef'],
    title: map['title'],
    price: map['price'],
    location: mapToAddressInfo(map['location']),
    description: map['description'],
    condition: condition,
    categories: categoryList,
    createdAt: map['createdAt'],
    favoriteCount: map['favoriteCount'],
    seenCount: map['seenCount'],
    reviewCount: map['reviewCount'],
    rateSum: map['rateSum']
  );

}
