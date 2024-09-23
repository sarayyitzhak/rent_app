import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ScrollableItemGrid extends StatelessWidget {
  Future<List<dynamic>>? future;
  ScrollController? controller;
  ScrollableItemGrid({super.key, required this.future, this.controller});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
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
