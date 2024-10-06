import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rent_app/widgets/item_card.dart';

import '../constants.dart';
import '../models/item.dart';
import '../services/firebase_services.dart';

class DynamicScrollableItemGrid extends StatelessWidget {
  Stream<dynamic>? stream;
  ScrollController? controller;
  DynamicScrollableItemGrid({super.key, required this.stream, this.controller});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: Text('אין פריטים להציג', style: kBlackHeaderTextStyle,)
            );
          }
          List<ItemCard> itemCards = getItemsByStream(snapshot.data?.docs);
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


      if (snapshot.hasData &&
          snapshot.data != null) {
        List? itemCards = snapshot.data;
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
      } else {
        return SizedBox(
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
    });



  }
}
