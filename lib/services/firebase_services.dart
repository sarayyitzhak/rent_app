import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/widgets/item_card.dart';

import '../models/category.dart';


Future<List> getItemsFilterByCategory(FirebaseFirestore firestore, ItemCategory category) async {
  List<Item> items = await getItemsByCategory(firestore, category);
  return getItemCards(items);
}

Future<List> getItemsFilterByContactUser(FirebaseFirestore firestore, DocumentReference contactUser) async {
  List<Item> items = await getItemsByContactUser(firestore, contactUser);
  return getItemCards(items);
}


Future<List> getUserItemsByField(UserDetails user, String dataField) async {
  List<Item> items = await getItemsListByField(user, dataField);
  return getItemCards(items);
}

List<ItemCard> getItemCards(List<Item> items) {
  List<ItemCard> itemCards = [];
  for (Item item in items) {
    itemCards.add(ItemCard(item: item));
  }
  return itemCards;
}

Future<List<Item>> getItemsListByField(UserDetails user, String dataField) async {
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

Future<List<Item>> getItemsByCategory(FirebaseFirestore firestore, ItemCategory category) async {
  List<Item> items = [];
  var getItems = await firestore.collection('items').where(
      'categories', arrayContains: category.idx).get();
  var itemsDoc = getItems.docs;
  if (itemsDoc.isNotEmpty) {
    for (var itemDoc in itemsDoc) {
      Map<String, dynamic>? itemData = itemDoc.data();
      var item = await mapAsItem(itemData, itemDoc.reference);
      if(item.contactUser != userDetails.userReference/* && !items.contains(item)*/){
        items.add(item);
      }
    }
  }
  return items;
}

Future<List<Item>> getItemsByContactUser(FirebaseFirestore firestore, DocumentReference contactUser) async {
  List<Item> items = [];
  var getItems = await firestore.collection('items').where(
      'contactUser', isEqualTo: contactUser).orderBy('createdAt', descending: true).get();
  var itemsDoc = getItems.docs;
  if (itemsDoc.isNotEmpty) {
    for (var itemDoc in itemsDoc) {
      Map<String, dynamic>? itemData = itemDoc.data();
      var item = await mapAsItem(itemData, itemDoc.reference);
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