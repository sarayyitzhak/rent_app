import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rent_app/widgets/request_card.dart';
import '../models/request.dart';

class ScrollableRequestList extends StatelessWidget {
  Future<List<ItemRequest>> future;
  ScrollableRequestList({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: future, builder: (context, snapshot) {
      if (snapshot.hasData) {
        List<RequestCard> requestCards = [];
        for (ItemRequest request in snapshot.data!) {
          requestCards.add(RequestCard(request: request));
        }
        return Expanded(
          child: ListView(
            children: requestCards,
          ),
        );
      } else {
        return Expanded(
          child: Center(
            child: LoadingAnimationWidget.stretchedDots(color: Colors.grey, size: 50),
          ),
        );
      }});
  }
}
