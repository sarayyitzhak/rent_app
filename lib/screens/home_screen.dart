import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rent_app/screens/user_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:rent_app/widgets/reusable_card.dart';
import 'package:rent_app/widgets/item_card.dart';
import '../constants.dart';
import 'package:rent_app/models/category.dart';

import '../models/item.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ItemCategory _selectedCategory = ItemCategory.values[0];
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final storageRef = FirebaseStorage.instance.ref();

  List<Widget> buildCategoriesList() {
    List<Widget> categoriesCards = [];

    for (ItemCategory category in ItemCategory.values) {
      categoriesCards.add(ReusableCard(
          color: _selectedCategory == category ? kActiveButtonColor : kLightYellow,
          cardChild: Icon(
            category.icon,
            color: _selectedCategory == category ? Colors.white : kPastelYellow,
          ),
          onPress: () {
            setState(() {
              _selectedCategory = category;
              //category swap
            });
          }));
    }
    return categoriesCards;
  }

  // List<Widget> buildBestSellerList(ItemCategory category) {
  //   List<Widget> items = ;
  //
  //
  //
  //
  //   for (int i = 0; i < 10; i++) {
  //     list.add(Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
  //       child: Container(color: kLightYellow,),//TODO: add itemCards
  //     ));
  //   }
  //   return list;
  // }

  Future<List> getItems(ItemCategory category) async {
    List<Item> items = await getItemsByCategory(category);
    return getItemCards(items);
  }

  List<ItemCard> getItemCards(List<Item> items) {
    List<ItemCard> itemCards = [];
    for (Item item in items) {
      itemCards.add(ItemCard(item: item));
    }
    return itemCards;
  }

  Future<List<Item>> getItemsByCategory(ItemCategory category) async {
    List<Item> items = [];
    var getItems = await _firestore.collection('items').where(
        'categories', arrayContains: category.title).get();
    var itemsDoc = getItems.docs;
    if (itemsDoc.isNotEmpty) {
      for (var itemDoc in itemsDoc) {
        Map<String, dynamic>? itemData = itemDoc.data();
        var item = mapAsItem(itemData);
        items.add(item);
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.hiWelcomeBack,
                          style: kTopHeaderTextStyle,
                        ),
                        Text(AppLocalizations.of(context)!.blah),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                AppLocalizations.of(context)!.categories,
                style: kHeadersTextStyle,
              ),
              Container(
                height: 85,
                child: ListView(
                  children: buildCategoriesList(),
                  scrollDirection: Axis.horizontal,
                ),
              ),
              Text(
                // 'Best Sellers of ${categories[_selectedCategoryIdx].title}',
                AppLocalizations.of(context)!.bestSellersOf(
                    _selectedCategory.title), //TODO: check how to do it with dynamic string
                style: kHeadersTextStyle,
              ),
              SizedBox(
                height: 15,
              ),
              Expanded(
                child: FutureBuilder(
                    future: getItems(_selectedCategory),
                    initialData: [Container(
                        height: 600,
                        child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 5,
                            children: [
                              LoadingAnimationWidget.waveDots(
                                  color: Colors.white, size: 10)]))],
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data!.isNotEmpty) {
                        List? itemCards = snapshot.data;
                        return GridView.count(

                          crossAxisCount: 2,
                          crossAxisSpacing: 1,
                          children: itemCards as List<Widget>,
                        );
                      } else {
                        return Container(
                          height: 600,
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            children: [
                              LoadingAnimationWidget.waveDots(
                                  color: Colors.white, size: 10)
                            ],
                          ),
                        );
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
