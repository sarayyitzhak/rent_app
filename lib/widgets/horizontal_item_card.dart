import 'package:cached_network_image/cached_network_image.dart';
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


class HorizontalItemCard extends StatelessWidget {
  final Item item;
  HorizontalItemCard({super.key, required this.item});
  late bool isMine;

  @override
  Widget build(BuildContext context) {
    IsInWishlist isInWishlist = IsInWishlist(userDetails.wishlist.contains(item.itemReference));
    isMine = item.contactUser == userDetails.userReference;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ItemScreen.id,
          arguments: ScreenArguments(item, isMine)),
      child: Container(
        // height: 40,
        width: 200,
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: item.imageRef,
                    placeholder: (context, url) => const CircularProgressIndicator(color: kPastelYellow,),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                            image: NetworkImage(
                              item.imageRef,
                            ),
                            scale: 0.5,
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
                const Text(
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
            const Divider(
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

