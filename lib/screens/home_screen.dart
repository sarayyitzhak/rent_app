import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rent_app/screens/user_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:rent_app/widgets/reusable_card.dart';
import 'package:rent_app/widgets/item_card.dart';
import '../constants.dart';
import 'package:rent_app/models/categories.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIdx = 0;

  List<Widget> buildCategoriesList() {
    List<Widget> categoriesCards = [];

    for (int i = 0; i < 10; i++) {
      categoriesCards.add(ReusableCard(
          color: _selectedCategoryIdx == i ? kActiveButtonColor : kLightYellow,
          cardChild: Icon(
            categories[i].icon,
            color: _selectedCategoryIdx == i ? Colors.white : kPastelYellow,
          ),
          onPress: () {
            setState(() {
              _selectedCategoryIdx = i;
              //category swap
            });
          }));
    }
    return categoriesCards;
  }

  List<Widget> buildBestSellerList() {
    List<Widget> list = [];
    for (int i = 0; i < 10; i++) {
      list.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
        child: ItemCard(),
      ));
    }
    return list;
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
                    categories[_selectedCategoryIdx]
                        .title), //TODO: check how to do it with dynamic string
                style: kHeadersTextStyle,
              ),
              SizedBox(
                height: 15,
              ),
              Expanded(
                  child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                children: buildBestSellerList(),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
