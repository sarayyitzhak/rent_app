import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  ItemCard({super.key, required this.item});

  late final _firestore = FirebaseFirestore.instance;
  late final _auth = FirebaseAuth.instance;
  late final _storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kLightYellow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Center(
                  child: Container(
                      // width: double.infinity,
                      child: Image.network(item.imageRef, fit: BoxFit.fill,),
                              ),
                )),

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
                Row(
                  children: [
                    IconButton(
                        padding: EdgeInsets.all(3),
                        constraints: BoxConstraints(),
                        style: const ButtonStyle(
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap, // the '2023' part
                        ),
                        onPressed: () {},
                        icon: CircleAvatar(
                          child: Icon(Icons.heart_broken, size: 15),
                          radius: 15,
                          backgroundColor: kActiveButtonColor,
                        )),
                    IconButton(
                        padding: EdgeInsets.all(3),
                        constraints: BoxConstraints(),
                        style: const ButtonStyle(
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap, // the '2023' part
                        ),
                        onPressed: () {},
                        icon: CircleAvatar(
                          child: Icon(Icons.messenger_outline, size: 15),
                          radius: 15,
                          backgroundColor: kActiveButtonColor,
                        ))
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
