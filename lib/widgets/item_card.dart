import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/screens/item_screen.dart';
import 'package:rent_app/widgets/chat_icon_button.dart';
import 'package:rent_app/widgets/wishlist_icon_button.dart';
import '../constants.dart';
import '../models/item.dart';

class IsInWishlist{
  bool value;
  IsInWishlist(this.value);
}


class ItemCard extends StatelessWidget {
  final Item item;
  ItemCard({super.key, required this.item});
  late bool isMine;

  @override
  Widget build(BuildContext context) {
    IsInWishlist isInWishlist = IsInWishlist(userDetails.wishlist.contains(item.itemReference));
    isMine = item.contactUser == userDetails.userReference;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ItemScreen.id,
          arguments: ScreenArguments(item, isMine)),
      child: Container(
        padding: EdgeInsets.all(5),
        // decoration: BoxDecoration(
        //   color: kLightYellow,
        //   borderRadius: BorderRadius.circular(10),
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    // image: DecorationImage(
                    //     image: NetworkImage(
                    //       item.imageRef,
                    //     ),
                    //     fit: BoxFit.cover),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: item.imageRef,
                    placeholder: (context, url) => CircularProgressIndicator(color: kPastelYellow,),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                            image: NetworkImage(
                              item.imageRef,
                            ),
                            fit: BoxFit.cover),
                      ),

                    ),
                  ),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.title,
                  style: kBlackHeaderTextStyle,
                ),
                Text(
                  '9.8',
                  style: kSmallBlackTextStyle,
                ),
              ],
            ), //description
            Text(
              item.location.addressDataToString(),
              style: kSmallBlackTextStyle,
            ), //place
             //place
            Divider(
              color: kPastelYellow,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item.price}₪',
                  style: kHeadersTextStyle,
                ), //price
                Container(
                  child: isMine ? null : Row(
                    children: [
                      WishlistIconButton(item: item,),
                      ChatIconButton(item: item,),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

