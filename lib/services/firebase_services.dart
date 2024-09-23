import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/widgets/horizontal_item_card.dart';
import 'package:rent_app/widgets/item_card.dart';

import '../models/category.dart';


Future<List> getItemsFilterByCategory(FirebaseFirestore firestore, ItemCategory category) async {
  List<Item> items = await _getItemsByCategory(firestore, category);
  return _getItemCards(items);
}

Future<List> getHorizontalItemsFilterByCategory(FirebaseFirestore firestore, ItemCategory category) async {
  List<Item> items = await _getItemsByCategory(firestore, category);
  return _getHorizontalItemCards(items);
}

Future<List> getHorizontalItemsFilterByLastSeen(FirebaseFirestore firestore) async {
  List<Item> items = await _getItemsLastSeen(firestore);
  return _getHorizontalItemCards(items);
}

Future<List> getHorizontalItemsFilterByLocation(FirebaseFirestore firestore, Position position, String cityName) async {
  List<Item> items = await _getItemsByLocation(firestore, position, cityName);
  return _getHorizontalItemCards(items);
}

Future<List> getItemsFilterByTitle(FirebaseFirestore firestore, String title) async {
  List<Item> items = await _getItemsByTitle(firestore, title);
  return _getItemCards(items);
}

Future<List> getItemsFilterByContactUser(FirebaseFirestore firestore, DocumentReference contactUser) async {
  List<Item> items = await _getItemsByContactUser(firestore, contactUser);
  return _getItemCards(items);
}


Future<List> getUserItemsByField(UserDetails user, String dataField) async {
  List<Item> items = await _getItemsListByField(user, dataField);
  return _getItemCards(items);
}

List<ItemCard> _getItemCards(List<Item> items) {
  List<ItemCard> itemCards = [];
  for (Item item in items) {
    itemCards.add(ItemCard(item: item));
  }
  return itemCards;
}

List<HorizontalItemCard> _getHorizontalItemCards(List<Item> items) {
  List<HorizontalItemCard> itemCards = [];
  for (Item item in items) {
    itemCards.add(HorizontalItemCard(item: item));
  }
  return itemCards;
}

Future<List<Item>> _getItemsListByField(UserDetails user, String dataField) async {
  List<Item> userItems = [];
  var userGetData = await user.userReference.get();
  Map<String, dynamic>? userData =
  userGetData.data() as Map<String, dynamic>?;
  List userItemsRefs = userData?[dataField];
  for (DocumentReference itemRef in userItemsRefs) {
    var itemGetData = await itemRef.get();
    if (itemGetData.exists) {
      Map<String, dynamic>? itemData =
      itemGetData.data()! as Map<String, dynamic>?;
      Item item = mapAsItem(itemData!, itemRef);
      userItems.add(item);
    }
  }
  return userItems;
}

Future<List<Item>> _getItemsByCategory(FirebaseFirestore firestore, ItemCategory category) async {
  List<Item> items = [];
  var getItems = await firestore.collection('items').where(
      'categories', arrayContains: category.idx).get();
  var itemsDoc = getItems.docs;
  if (itemsDoc.isNotEmpty) {
    for (var itemDoc in itemsDoc) {
      Map<String, dynamic>? itemData = itemDoc.data();
      var item = mapAsItem(itemData, itemDoc.reference);
      if(item.contactUser != userDetails.userReference/* && !items.contains(item)*/){
        items.add(item);
      }
    }
  }
  return items;
}

Future<List<Item>> _getItemsLastSeen(FirebaseFirestore firestore) async {
  List<Item> items = [];
  var userDoc = await userDetails.userReference.get();
  Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
  List lastSeen = userData['seen'];
  if(lastSeen.isNotEmpty) {
    for (var lastSeenItem in lastSeen) {
      var itemDoc = await lastSeenItem.get();
      Map<String, dynamic> itemData = itemDoc.data();
      var item = mapAsItem(itemData, itemDoc.reference);
      if (item.contactUser !=
          userDetails.userReference /* && !items.contains(item)*/) {
        items.add(item);
      }
    }
  }
  return items.reversed.toList();
}

Future<List<Item>> _getItemsByLocation(FirebaseFirestore firestore, Position position, String cityName) async {
  List<Item> items = [];
  var getItems = await firestore.collection('items').where(
      'location.city', isEqualTo: cityName).get();
  var itemsDoc = getItems.docs;
  if (itemsDoc.isNotEmpty) {
    for (var itemDoc in itemsDoc) {
      Map<String, dynamic>? itemData = itemDoc.data();
      var item = mapAsItem(itemData, itemDoc.reference);
      if(item.contactUser != userDetails.userReference/* && !items.contains(item)*/){
        items.add(item);
      }
    }
  }
  return items;
}

Future<List<Item>> _getItemsByContactUser(FirebaseFirestore firestore, DocumentReference contactUser) async {
  List<Item> items = [];
  var getItems = await firestore.collection('items').where(
      'contactUser', isEqualTo: contactUser).orderBy('createdAt', descending: true).get();
  var itemsDoc = getItems.docs;
  if (itemsDoc.isNotEmpty) {
    for (var itemDoc in itemsDoc) {
      Map<String, dynamic>? itemData = itemDoc.data();
      var item = mapAsItem(itemData, itemDoc.reference);
      items.add(item);
    }
  }
  return items;
}

Future<List<Item>> _getItemsByTitle(FirebaseFirestore firestore, String title) async {
  List<Item> items = [];
  var getItems = await firestore.collection('items').where('title', isEqualTo: title).get();
  var itemsDoc = getItems.docs;
  if (itemsDoc.isNotEmpty) {
    for (var itemDoc in itemsDoc) {
      Map<String, dynamic>? itemData = itemDoc.data();
      var item = mapAsItem(itemData, itemDoc.reference);
      items.add(item);
    }
  }
  return items;
}

Future<UserDetails> getItemContactUser(Item item) async {
  var contactUserDoc = await item.contactUser.get();
  Map<String, dynamic>? contactUserData = contactUserDoc.data() as Map<String, dynamic>?;
  return mapAsUser(contactUserData!);
}