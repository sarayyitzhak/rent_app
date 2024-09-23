import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/widgets/chat_icon_button.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/custom_button.dart';
import 'package:rent_app/widgets/wishlist_icon_button.dart';

import '../services/firebase_services.dart';
import '../widgets/dial_icon_button.dart';

class ItemScreen extends StatelessWidget {
  static String id = 'item_screen.dart';
  const ItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
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
              return const Center(child: Text('Error loading seller details'));
            } else if (snapshot.hasData) {
              UserDetails contactUser = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: kLightYellow,
                        // borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage(item.imageRef),
                          fit: BoxFit.cover,
                        ),
                      ),
                      height: 300,
                    ),
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
                                  '${item.likesCount} אנשים אהבו את המודעה ', style: kSmallBlackTextStyle,),
                                leading: const Icon(Icons.favorite),
                                iconColor: Colors.pinkAccent,
                              ) //Text('${item.likesCount} אנשים אהבו את המודעה שלך'),
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
                                '${item.seenCount} אנשים צפו במודעה ', style: kSmallBlackTextStyle,),
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
                          child: Text(item.condition.title),
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
                            DialIconButton(
                                phoneNumber: '0${contactUser.phoneNumber}'),
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
                              '${item.price}₪',
                              style: kHeadersTextStyle,
                            ),
                            arg.isMe
                                ? Container()
                                : Row(
                                    children: [
                                      WishlistIconButton(item: item),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      ChatIconButton(
                                        item: item,
                                      ),
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
                          title: arg.isMe ? 'ערוך' : localization.rentItem,
                          onPress: () {})),
                ],
              );
            }
            return Container();
          }),
    );
  }
}

class ScreenArguments {
  final Item item;
  final bool isMe;
  ScreenArguments(this.item, this.isMe);
}
