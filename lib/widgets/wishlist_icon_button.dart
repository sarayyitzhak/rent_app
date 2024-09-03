import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/screens/item_screen.dart';
import 'package:rent_app/widgets/wishlist_icon_button.dart';
import '../constants.dart';
import '../models/item.dart';
import 'package:rent_app/main.dart';

class WishlistIconButton extends StatefulWidget {
  Item item;
  WishlistIconButton({super.key, required this.item});

  @override
  State<WishlistIconButton> createState() => _WishlistIconButtonState();
}

class _WishlistIconButtonState extends State<WishlistIconButton> {
  @override
  Widget build(BuildContext context) {
    bool isIn = userDetails.wishlist.contains(widget.item.itemReference);
    return IconButton(
        padding: EdgeInsets.all(3),
        constraints: BoxConstraints(),
        style: const ButtonStyle(
          tapTargetSize: MaterialTapTargetSize
              .shrinkWrap, // the '2023' part
        ),
        onPressed: () {
          setState(() {
            if(isIn){
              isIn = false;
              userDetails.wishlist.remove(widget.item.itemReference);
              userDetails.userReference.update({'wishlist': FieldValue.arrayRemove([widget.item.itemReference])});
            } else {
              isIn = true;
              userDetails.wishlist.add(widget.item.itemReference);
              userDetails.userReference.update({'wishlist': FieldValue.arrayUnion([widget.item.itemReference])});
            }
          });

        },
        icon: CircleAvatar(
          child: Icon(Icons.favorite, size: 15, color: isIn ? kActiveButtonColor : kWhiteColor,),
          radius: 15,
          backgroundColor: isIn ? kLightYellow : kActiveButtonColor,
        ));
  }
}

