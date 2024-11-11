import 'package:flutter/material.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/review_card.dart';
import '../dictionary.dart';
import '../models/item.dart';
import '../models/item_review.dart';

class ReviewsScreen extends StatelessWidget {
  static String id = 'reviews_screen';
  final ReviewsScreenArguments args;
  const ReviewsScreen(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    Item item = args.item;
    var localization = Dictionary.getLocalization(context);
    return Scaffold(
      appBar: CustomAppBar(title: localization.reviews),
      body: FutureBuilder(
        future: getItemReviews(item.docRef),
        builder: (BuildContext context, AsyncSnapshot<List<ItemReview>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } if (snapshot.hasData) {
            List<ItemReview> reviews = snapshot.data!;
            return ListView(
              physics: const ClampingScrollPhysics(),
              children: reviews.map((r) => ReviewCard(review: r)).toList(),
            );
          } else {
            return const Center(child: Text('error'));
          }
        },
      ),
    );
  }
}

class ReviewsScreenArguments {
  final Item item;
  ReviewsScreenArguments(this.item);
}
