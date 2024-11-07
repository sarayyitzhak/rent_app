import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/globals.dart';
import 'package:rent_app/models/condition.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/item_review.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/screens/add_item_screen.dart';
import 'package:rent_app/screens/rental_screen.dart';
import 'package:rent_app/screens/reviews_screen.dart';
import 'package:rent_app/utils.dart';
import 'package:rent_app/widgets/chat_icon_button.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/custom_button.dart';
import 'package:rent_app/widgets/rating_stars.dart';
import 'package:rent_app/widgets/rating_stars_widget.dart';
import 'package:rent_app/widgets/favorite_button.dart';

import '../services/cloud_services.dart';
import '../widgets/dial_icon_button.dart';

class ItemScreen extends StatelessWidget {
  static String id = 'item_screen.dart';

  final ItemScreenArguments args;

  const ItemScreen(this.args, {super.key});

  Row commentWidget(BuildContext context, double rate, TextEditingController commentController, Item item) {
    var localization = AppLocalizations.of(context)!;
    return Row(
      children: [
        TextButton(onPressed: () {}, child: Text(localization.addComment)),
        Expanded(
          child: Column(
            children: [
              TextField(
                controller: commentController,
              ),
              RatingStarsRow(onChanged: (v) => rate = v),
            ],
          ),
        ),
        ElevatedButton(
            onPressed: () {
              if(rate == 0){
                addItemReview(item.docRef, rate.toInt(), commentController.text);
                commentController.clear();
              }
            },
            child: Text('הגב')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Item item = args.item;
    var localization = AppLocalizations.of(context)!;
    double rate = 0;
    TextEditingController commentController = TextEditingController();

    if (userDetails.docRef.id != item.contactUserID) {
      updateUserItemSeen(item.docRef);
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        isBackButton: true,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: getUserByID(item.contactUserID),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text(localization.errorLoadingSellerDetails));
              } else if (snapshot.hasData) {
                UserDetails contactUser = snapshot.data!;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: kLightYellow,
                        image: DecorationImage(
                          image: NetworkImage(item.imageRef),
                          fit: BoxFit.cover,
                        ),
                      ),
                      height: 300,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          args.isMe
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Container(
                                          // padding: EdgeInsets.all(10),
                                          margin: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: kPastelYellowOpacity, borderRadius: BorderRadius.circular(10)),
                                          child: ListTile(
                                            title: Text(
                                              '${item.favoriteCount} ${localization.peopleLikedTheItem} ',
                                              style: kSmallBlackTextStyle,
                                            ),
                                            leading: const Icon(Icons.favorite),
                                            iconColor: Colors.pinkAccent,
                                          )),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: kPastelYellowOpacity, borderRadius: BorderRadius.circular(10)),
                                        child: ListTile(
                                          title: Text('${item.seenCount} ${localization.peopleSeenTheItem} ',
                                              style: kSmallBlackTextStyle),
                                          leading: const Icon(Icons.remove_red_eye),
                                          iconColor: Colors.blue.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              item.title,
                              style: kBlackHeaderTextStyle,
                            ),
                          ),
                          Text(
                            item.description,
                            style: kSmallBlackTextStyle,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: kPastelYellowOpacity,
                            ),
                            child: Text(item.condition.getTitle(localization)),
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 1,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localization.contactUserDetails,
                                    style: kBlackHeaderTextStyle,
                                  ),
                                  Text(
                                    contactUser.name,
                                    style: kBlackTextStyle,
                                  ),
                                  // Text('0${contactUser.phoneNumber}'),
                                  Text(
                                    item.location.addressDataToString(),
                                    style: kBlackTextStyle,
                                  ),
                                ],
                              ),
                              DialIconButton(phoneNumber: phoneNumberToString(contactUser.phoneNumber)),
                            ],
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 1,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                getFormattedPrice(item.price),
                                style: kHeadersTextStyle,
                              ),
                              args.isMe
                                  ? Container()
                                  : Row(
                                      children: [
                                        FavoriteButton(item: item),
                                        const SizedBox(width: 5),
                                        ChatIconButton(item: item),
                                      ],
                                    )
                            ],
                          ),
                          item.getRate() != null
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      child: Text('${localization.usersReviews} (${item.reviewCount})'),
                                      onPressed: () => Navigator.pushNamed(context, ReviewsScreen.id, arguments: ReviewsScreenArguments(item)),
                                    ),
                                    RatingStarsWidget(rate: item.getRate()!)
                                  ],
                                )
                              : Text(localization.noReviewsYet),
                          commentWidget(context, rate, commentController, item),
                        ],
                      ),
                    ),
                    Center(
                        child: CustomButton(
                      title: args.isMe ? localization.edit : localization.rentItem,
                      onPress: args.isMe
                          ? () => Navigator.pushNamed(context, AddItemScreen.id,
                              arguments: AddItemScreenArguments(item: item, isEditMode: true))
                          : () => Navigator.pushNamed(context, RentalScreen.id,
                              arguments: RentalScreenArguments(item: item)),
                    )),
                  ],
                );
              }
              return Container();
            }),
      ),
    );
  }
}

class ItemScreenArguments {
  final Item item;
  final bool isMe;

  ItemScreenArguments(this.item, this.isMe);
}
