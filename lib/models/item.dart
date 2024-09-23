
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/services/address_services.dart';
import 'category.dart';
import 'condition.dart';

class Item{
  //Image
  late DocumentReference itemReference;
  late DocumentReference contactUser;
  late String imageRef;
  late String title;
  late int price;
  // DateTime uploadTime;
  late AddressInfo location;
  late String description;
  late Condition condition;
  late List<dynamic> categories;
  late Timestamp createdAt;
  late int likesCount;
  late int seenCount;
  // List<String> reviews;
  Item({required this.itemReference, required this.contactUser, required this.imageRef, required this.title, required this.price, required this.location, required this.description, required this.condition, required this.categories, required this.createdAt, required this.likesCount, required this.seenCount});


  Map<String, dynamic> itemAsMap(){
    return {
      'contactUser': contactUser,
      'imageRef': imageRef,
      'title': title,
      'price': price,
      'location': {'city': location.addressData['city'], 'road': location.addressData['road'] ?? ''},
      'description': description,
      'condition': condition.idx,
      'categories': categories.map((c) => c.idx).toList(),
      'createdAt': createdAt,
      'likesCount': likesCount,
      'seenCount': seenCount
      // 'uploadTime':
    };
  }


}

Item mapAsItem(Map<String, dynamic> map, DocumentReference itemRef){
  AddressInfo location = AddressInfo(latitude: 0, longitude: 0, addressData: {'city': map['location']['city'], 'road': map['location']['road']});

  var categoryTitlesList = map['categories'];
  List<ItemCategory> categoryList = [];
  for(int idx in categoryTitlesList){
    categoryList.add(getCategoryByIdx(idx));
  }
  Condition condition = getCondFromIdx(map['condition']);
  // uploadTime = DateTime()
  Item item = Item(itemReference: itemRef, contactUser: map['contactUser'], imageRef: map['imageRef'], title: map['title'], price: map['price'], location: location, description: map['description'], condition: condition, categories: categoryList, createdAt: map['createdAt'], likesCount: map['likesCount'], seenCount: map['seenCount']);
  return item;
}