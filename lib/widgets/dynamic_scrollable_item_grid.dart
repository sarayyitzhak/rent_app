import 'package:flutter/material.dart';
import 'package:rent_app/widgets/item_widgets/item_card.dart';
import '../constants.dart';
import '../dictionary.dart';
import '../services/card_utils.dart';


class DynamicScrollableItemGrid extends StatelessWidget {
  Stream<dynamic>? stream;
  ScrollController? controller;
  DynamicScrollableItemGrid({super.key, required this.stream, this.controller});

  @override
  Widget build(BuildContext context) {
    var localization = Dictionary.getLocalization(context);
    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: Text(localization.noItemsToShow, style: kBlackHeaderTextStyle,)
            );
          }
          List<ItemCard> itemCards = getItemsByStream(snapshot.data?.docs, false);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 0,
              childAspectRatio: 0.71,
              controller: controller,
              children: itemCards as List<Widget>,
            ),
          );
    },
    );
  }
}
