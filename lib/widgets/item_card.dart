import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import '../constants.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
                  child: Image.network(
                      'https://images.pexels.com/photos/2820884/pexels-photo-2820884.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'))),
          Text(
            'Product Name',
            style: kHeadersTextStyle,
          ), //description
          Text(
            'Tel Aviv',
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
                '98\$',
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
    );
  }
}
