import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/models/category.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/scrollable_item_grid.dart';

import '../services/firebase_services.dart';

class CategoryScreen extends StatelessWidget {
  static String id = 'category_screen';
  CategoryScreen({super.key});
  late ItemCategory category;
  final _firestore = FirebaseFirestore.instance;
  
  List<Widget> createListOfSubCategories(List titles){
    List<Widget> subCategories = [];
    for(String title in titles){
      subCategories.add(TextButton(onPressed: () {}, child: Text(title)));
      subCategories.add(Container(padding: EdgeInsets.symmetric(horizontal: 5), child: VerticalDivider(color: kPastelYellow, width: 3, thickness: 1,), height: 10,));
    }
    return subCategories;
  }
  
  ListView buildListView(){
    return ListView(
      scrollDirection: Axis.horizontal,
      children: createListOfSubCategories(['מברגות', 'מקדחות', 'פטישים', 'כלי גינון', 'כלים סניטריים', 'כלים גדולים']),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    final arg =
        ModalRoute.of(context)!.settings.arguments as CategoryScreenArguments;
    category = arg.category;
    return Scaffold(
        appBar: CustomAppBar(title: category.title),
        body: Column(
          children: [
            Container(
              height: 35,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: buildListView(),
            ),
            Expanded(
              child: ScrollableItemGrid(
                  future: getItemsFilterByCategory(_firestore, category)),
            ),
          ],
        ));
  }
}

class CategoryScreenArguments {
  final ItemCategory category;
  CategoryScreenArguments(this.category);
}
