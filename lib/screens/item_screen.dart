import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/add_users.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/models/condition.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/screens/add_item_screen.dart';
import 'package:rent_app/screens/rental_screen.dart';
import 'package:rent_app/utils.dart';
import 'package:rent_app/widgets/chat_icon_button.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/custom_button.dart';
import 'package:rent_app/widgets/wishlist_icon_button.dart';

import '../services/cloud_services.dart';
import '../widgets/dial_icon_button.dart';

class ItemScreen extends StatelessWidget {
  static String id = 'item_screen.dart';
  const ItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as ItemScreenArguments;
    Item item = arg.item;
    var localization = AppLocalizations.of(context)!;
    if (userDetails.userReference != item.contactUser && !userDetails.seen.contains(item.itemReference)) {
      item.itemReference.update({'seenCount': FieldValue.increment(1)});
      userDetails.userReference.update({
        'seen': FieldValue.arrayUnion([item.itemReference])
      });
      userDetails.seen.add(item.itemReference);
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        isBackButton: true,
      ),
      body: FutureBuilder(
          future: getItemContactUser(item),
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
                        arg.isMe
                            ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            // padding: EdgeInsets.all(10),
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: kPastelYellowOpacity,
                                  borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                title: Text(
                                  '${item.likesCount} ${localization.peopleLikedTheItem} ', style: kSmallBlackTextStyle,),
                                leading: const Icon(Icons.favorite),
                                iconColor: Colors.pinkAccent,
                              )
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: kPastelYellowOpacity,
                                borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              title: Text(
                                '${item.seenCount} ${localization.peopleSeenTheItem} ', style: kSmallBlackTextStyle),
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
                              priceToString(item.price),
                              style: kHeadersTextStyle,
                            ),
                            arg.isMe
                                ? Container()
                                : Row(
                                    children: [
                                      WishlistIconButton(item: item),
                                      const SizedBox(width: 5),
                                      ChatIconButton(item: item),
                                    ],
                                  )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localization.usersReviews,
                              style: kSmallBlackTextStyle,
                            ),
                            const Text('9.8'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Center(
                      child: CustomButton(
                          title: arg.isMe ? localization.edit : localization.rentItem,
                          onPress: arg.isMe
                              ? () => Navigator.pushNamed(context, AddItemScreen.id, arguments: AddItemScreenArguments(item: item, isEditMode: true))
                              : () => Navigator.pushNamed(context, RentalScreen.id, arguments: RentalScreenArgument(item: item)),
                      )
                  ),
                ],
              );
            }
            return Container();
          }),
    );
  }
}

class ItemScreenArguments {
  final Item item;
  final bool isMe;
  ItemScreenArguments(this.item, this.isMe);
}
