import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/widgets/reusable_card.dart';
import '../add_users.dart';
import '../constants.dart';
import 'package:rent_app/models/category.dart';
import '../services/firebase_services.dart';
import '../widgets/scrollable_item_grid.dart';

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



  @override
  Widget build(BuildContext context) {
    // create10Users();
    // return Text('finished');
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                            Text('מה תרצו לחפש?', style: kBlackTextStyle,),
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
                ],
              ),
            ),
            Expanded(child: ScrollableItemGrid(future: getItemsFilterByCategory(_firestore, _selectedCategory),)),
          ],
        ),
      ),
    );
  }
}
