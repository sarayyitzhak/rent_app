import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/main.dart';
import '../constants.dart';
import '../models/item.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 3),
        constraints: const BoxConstraints(),
        style: const ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
        ),
        onPressed: () {
          setState(() {
            if (isIn) {
              userDetails.wishlist.remove(widget.item.itemReference);
              userDetails.userReference.update({
                'wishlist': FieldValue.arrayRemove([widget.item.itemReference])
              });
              widget.item.itemReference.update({'likesCount': FieldValue.increment(-1)});
            } else {
              userDetails.wishlist.add(widget.item.itemReference);
              userDetails.userReference.update({
                'wishlist': FieldValue.arrayUnion([widget.item.itemReference])
              });
              widget.item.itemReference.update({'likesCount': FieldValue.increment(1)});
            }
            isIn = !isIn;
          });
        },
        icon: Icon(isIn ? Icons.favorite : Icons.favorite_outline, size: 25, color: isIn ? Colors.red : Colors.white));
  }
}
