import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../services/card_utils.dart';

class ScrollableRequestList extends StatelessWidget {
  Future<QuerySnapshot<Map<String, dynamic>>> future;
  var localization;
  bool isMyRequest;
  ScrollableRequestList({super.key, required this.localization, required this.future, required this.isMyRequest});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: getPendingRequests(future, isMyRequest, localization), builder: (context, snapshot) {
      if (snapshot.hasData &&
          snapshot.data != null &&
          snapshot.data!.isNotEmpty) {
        List? requestCards = snapshot.data;
        return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 600,
              width: double.infinity,
              child: ListView(
                children: requestCards as List<Widget>,
              ),
            )
        );
      } else {
        return SizedBox(
          height: 600,
          child: GridView.count(
            crossAxisCount: 1,
            crossAxisSpacing: 15,
            children: [
              LoadingAnimationWidget.waveDots(
                  color: Colors.white, size: 10)
            ],
          ),
        );
      }});
  }
}
