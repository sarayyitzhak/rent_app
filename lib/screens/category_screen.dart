import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/models/category.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/item_widgets/item_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/card_utils.dart';

class CategoryScreen extends StatelessWidget {
  static String id = 'category_screen';

  final CategoryScreenArguments args;

  const CategoryScreen(this.args, {super.key});

  List<Widget> createListOfSubCategories(List titles) {
    List<Widget> subCategories = [];
    for (String title in titles) {
      subCategories.add(TextButton(onPressed: () {}, child: Text(title)));
      subCategories.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        height: 10,
        child: const VerticalDivider(
          color: kPastelYellow,
          width: 3,
          thickness: 1,
        ),
      ));
    }
    return subCategories;
  }

  ListView buildListView() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: createListOfSubCategories(['מברגות', 'מקדחות', 'פטישים', 'כלי גינון', 'כלים סניטריים', 'כלים גדולים']),
    );
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: CustomAppBar(title: args.category.getTitle(localization)),
        body: Column(
          children: [
            Container(
              height: 35,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: buildListView(),
            ),
            Expanded(
              child: ItemGrid((DocumentSnapshot? startAfterDoc) => getItemsByCategory(args.category, startAfterDoc)),
            )
          ],
        ));
  }
}

class CategoryScreenArguments {
  final ItemCategory category;

  CategoryScreenArguments(this.category);
}
