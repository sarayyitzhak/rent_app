import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/widgets/item_widgets/item_card.dart';
import '../models/category.dart';
import '../utils.dart';
import 'cloud_services.dart';


//ITEM CARDS
List<ItemCard> getItemCards(List<Item> items, bool isHorizontal) {
  List<ItemCard> itemCards = [];
  for (Item item in items) {
    itemCards.add(ItemCard(item: item, isHorizontal: isHorizontal));
  }
  return itemCards;
}

List<ItemCard> getItemsByStream(dynamic items, bool isHorizontal){
  List<Item> itemsList = [];
  for (var itemDoc in items) {
    itemsList.add(Item.fromDocumentSnapshot(itemDoc));
  }
  return getItemCards(itemsList, isHorizontal);
}