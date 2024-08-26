
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/services/address_services.dart';
import 'package:rent_app/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import '../constants.dart';
import 'package:rent_app/utils.dart';
import '../main.dart';
import 'category.dart';

class Item{
  //Image
  late String userUid;
  late String imageRef;
  late String title;
  late double price;
  // DateTime uploadTime;
  late AddressInfo location;
  late String description;
  late String condition;
  late List<dynamic> categories;
  // List<String> likes = [];
  // List<String> reviews;
  Item({required this.userUid, required this.imageRef, required this.title, required this.price, required this.location, required this.description, required this.condition, required this.categories});


  Map<String, dynamic> itemAsMap(){
    return {
      'userUid': userUid,
      'imageRef': imageRef,
      'title': title,
      'price': price,
      'location': {'city': location.addressData['city'], 'road': location.addressData['road'] != null ? location.addressData['road'] : ''},
      'description': description,
      'condition': condition,
      'categories': categories.map((c) => c.title).toList(),
      // 'uploadTime':
    };
  }


}

Item mapAsItem(Map<String, dynamic> map){
  AddressInfo location = AddressInfo(latitude: 0, longitude: 0, addressData: {'city': map['location']['city'], 'road': map['location']['road']});
  var categoryTitlesList = map['categories'];
  List<ItemCategory> categoryList = [];
  for(String title in categoryTitlesList){
    categoryList.add(getCategoryBtTitle(title));
  }
  // uploadTime = DateTime()
  Item item = Item(userUid: map['userUid'], imageRef: map['imageRef'], title: map['title'], price: map['price'], location: location, description: map['description'], condition: map['condition'], categories: categoryList);
  return item;
}