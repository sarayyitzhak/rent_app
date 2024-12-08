import 'package:flutter/material.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/screens/item_grid_screen.dart';
import 'package:rent_app/screens/item_requests_screen.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/services/query_batch.dart';
import 'package:rent_app/widgets/home_widgets/around_you_container.dart';
import 'package:rent_app/widgets/reusable_card.dart';
import '../constants.dart';
import 'package:rent_app/models/category.dart';
import '../dictionary.dart';

import '../widgets/item_widgets/item_card.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ItemCategory _selectedCategory = ItemCategory.values[0];
  final ScrollController _categoryScrollController = ScrollController();

  List<Widget> buildCategoriesList() {
    List<Widget> categoriesCards = [];

    for (ItemCategory category in ItemCategory.values) {
      categoriesCards.add(ReusableCard(
          color: _selectedCategory == category ? kActiveButtonColor : kPastelYellowOpacity,
          cardChild: Icon(
            category.icon,
            color: _selectedCategory == category ? Colors.white : kPastelYellow,
          ),
          onPress: () {
            setState(() {
              _selectedCategory = category;
              _categoryScrollController.initialScrollOffset;
            });
          }));
    }
    return categoriesCards;
  }

  @override
  Widget build(BuildContext context) {
    // create10Users();
    // return Text('finished');
    var localization = Dictionary.getLocalization(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localization.hiWelcomeBack,
                                style: kTopHeaderTextStyle,
                              ),
                            ],
                          ),
                          IconButton(
                              onPressed: () => Navigator.pushNamed(context, ItemRequestsScreen.id),
                              icon: Icon(
                                Icons.pending_outlined,
                                color: kDarkYellow,
                              )),
                        ],
                      ),
                    ),
                    Text(
                      localization.whatWouldYouLikeToSearch,
                      style: kBlackTextStyle,
                    ),
                    SizedBox(
                      height: 85,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: buildCategoriesList(),
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    Text(
                      localization.recommendedForYou,
                      style: kBlackHeaderTextStyle,
                    ),
                    SizedBox(
                      height: 250,
                      child: FutureBuilder(
                          future: getItemsByCategory(_selectedCategory),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              QueryBatch<Item> items = snapshot.data!;
                              return ListView(
                                scrollDirection: Axis.horizontal,
                                children: items.list.map((Item item) => ItemCard(item: item, isHorizontal: true)).toList(),
                              );
                            } else {
                              return Container();
                            }
                          }),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    const AroundYouContainer(),

                    const SizedBox(
                      height: 30,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localization.lastSeen,
                          style: kBlackHeaderTextStyle,
                        ),
                        TextButton(
                            onPressed: () => Navigator.pushNamed(context, ItemGridScreen.id,
                                arguments: ItemGridScreenArguments(localization.lastSeen, getUserSeenItems)),
                            child: Text(
                              localization.show_more,
                              style: const TextStyle(color: Colors.black54),
                            ))
                      ],
                    ),
                    SizedBox(
                      height: 250,
                      child: FutureBuilder(
                          future: getUserSeenItems(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              QueryBatch<Item> items = snapshot.data!;
                              return ListView(
                                scrollDirection: Axis.horizontal,
                                children:
                                    items.list.map((Item item) => ItemCard(item: item, isHorizontal: true)).toList(),
                              );
                            } else {
                              return Container();
                            }
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
