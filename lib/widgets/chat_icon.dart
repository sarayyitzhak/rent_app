import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/screens/item_screen.dart';
import 'package:rent_app/widgets/wishlist_icon.dart';
import '../constants.dart';
import '../models/item.dart';


class ChatIconButton extends StatefulWidget {
  ChatIconButton({super.key});

  @override
  State<ChatIconButton> createState() => _ChatIconButtonState();
}

class _ChatIconButtonState extends State<ChatIconButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        padding: EdgeInsets.all(3),
        constraints: BoxConstraints(),
        style: const ButtonStyle(
          tapTargetSize: MaterialTapTargetSize
              .shrinkWrap, // the '2023' part
        ),
        onPressed: () {
          setState(() {
          });

        },
        icon: CircleAvatar(
          child: Icon(Icons.chat_bubble, size: 15, color: kWhiteColor,),
          radius: 15,
          backgroundColor: kActiveButtonColor,
        ));
  }
}

