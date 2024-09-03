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
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, ItemScreen.id,
            arguments: ScreenArguments(item)),
        child: Container(
          padding: EdgeInsets.all(10),
          // decoration: BoxDecoration(
          //   color: kLightYellow,
          //   borderRadius: BorderRadius.circular(10),
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                          item.imageRef,
                        ),
                        fit: BoxFit.fill),
                  ),
                ),
              ),

              Text(
                item.title,
                style: kHeadersTextStyle,
              ), //description
              Text(
                item.location.addressDataToString(),
                style: kSmallBlackTextStyle,
              ), //place
              Text(
                '9.8',
                style: kSmallBlackTextStyle,
              ), //place
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
      ),
    );
  }
}

