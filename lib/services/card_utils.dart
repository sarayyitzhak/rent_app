import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/widgets/item_card.dart';
import '../models/category.dart';
import '../models/request.dart';
import '../utils.dart';
import '../widgets/request_card.dart';
import 'cloud_services.dart';


//ITEM CARDS
List<ItemCard> getItemCards(List<Item> items, bool isHorizontal) {
  List<ItemCard> itemCards = [];
  for (Item item in items) {
    itemCards.add(ItemCard(item: item, isHorizontal: isHorizontal));
  }
  return itemCards;
}

Future<List<ItemCard>> getItemsFilterByCategory(ItemCategory category, bool isHorizontal) async {
  List<Item> items = await getItemsByCategory(category);
  return getItemCards(items, isHorizontal);
}

Future<List<ItemCard>> getItemsFilterByLocation(Position position, String cityName, bool isHorizontal) async {
  List<Item> items = await getItemsByLocation(position, cityName);
  return getItemCards(items, isHorizontal);
}

Future<List<ItemCard>> getItemsFilterByGeoPoint(double lat, double lng, bool isHorizontal) async {
  Map latLng = getLatLngSquare(lat, lng);
  List<Item> items = await getItemsByGeoPoint(latLng['minLat'], latLng['maxLat'], latLng['minLng'], latLng['maxLng']);
  return getItemCards(items, isHorizontal);
}

Future<List<ItemCard>> getItemsFilterByTitle(String title, bool isHorizontal) async {
  List<Item> items = await getItemsByTitle(title);
  return getItemCards(items, isHorizontal);
}

Future<List<ItemCard>> getItemsFilterByContactUser(DocumentReference contactUser, bool isHorizontal) async {
  List<Item> items = await getItemsByContactUser(contactUser);
  return getItemCards(items, isHorizontal);
}

Future<List<ItemCard>> getUserItemsLastSeen(UserDetails user, bool isHorizontal, bool reversed) async {
  return getUserItemsByField(userDetails, 'seen', isHorizontal, reversed);
}

Future<List<ItemCard>> getUserItemsWishlist(UserDetails user, bool isHorizontal, bool reversed) async {
  return getUserItemsByField(userDetails, 'wishlist', false, false);
}

Future<List<ItemCard>> getUserItemsByField(UserDetails user, String dataField, bool isHorizontal, bool reversed) async {
  List<Item> items = await getItemsListByField(user, dataField, reversed);
  return getItemCards(items, isHorizontal);
}

List<ItemCard> getItemsByStream(dynamic items, bool isHorizontal){
  List<Item> itemsList = [];
  for (var itemDoc in items) {
    Map<String, dynamic>? itemData = itemDoc.data();
    var item = mapAsItem(itemData!, itemDoc.reference);
    itemsList.add(item);
  }
  return getItemCards(itemsList, isHorizontal);
}

//REQUEST CARDS
List<RequestCard> _getRequestCards(List<ItemRequest> requests, bool isMyRequest, var localization) {
  List<RequestCard> requestCards = [];
  for (ItemRequest request in requests) {
    requestCards.add(RequestCard(request: request, isMyRequest: isMyRequest, localization: localization));
  }
  return requestCards;
}

Future<List<RequestCard>> getPendingRequests(Future<QuerySnapshot<Map<String, dynamic>>> future, bool isMyRequest, var localization) async {
  List<ItemRequest> requests = await getRequestsByFuture(future);
  return _getRequestCards(requests, isMyRequest, localization);
}