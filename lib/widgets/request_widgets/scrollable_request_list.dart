import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rent_app/widgets/request_widgets/request_card.dart';
import '../../models/item_request.dart';

class ScrollableRequestList extends StatelessWidget {
  final Future<List<ItemRequest>> future;
  const ScrollableRequestList({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: future, builder: (context, snapshot) {
      if (snapshot.hasData) {
        return ListView(
          children: snapshot.data!.map((request) => RequestCard(request: request)).toList(),
        );
      } else {
        return Center(
          child: LoadingAnimationWidget.stretchedDots(color: Colors.grey, size: 50),
        );
      }});
  }
}
