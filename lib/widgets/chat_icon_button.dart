import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/models/chat.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/screens/chat_screen.dart';
import '../constants.dart';
import '../models/item.dart';
import '../services/cloud_services.dart';

class ChatIconButton extends StatefulWidget {
  Item item;
  ChatIconButton({super.key, required this.item});

  @override
  State<ChatIconButton> createState() => _ChatIconButtonState();
}

class _ChatIconButtonState extends State<ChatIconButton> {

  @override
  Widget build(BuildContext context) {
    return IconButton(
        padding: const EdgeInsets.all(3),
        constraints: const BoxConstraints(),
        style: const ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
        ),
        onPressed: () async {
          Chat chat = await sendItemMessage(widget.item.contactUser, widget.item.itemReference);
          UserDetails userDetails = await getUserByID(widget.item.contactUser.id);
          if (mounted) {
            Navigator.pushNamed(context, ChatScreen.id, arguments: ChatScreenArguments(chat, userDetails.name));
          }
        },
        icon: const CircleAvatar(
          radius: kIconRadius,
          backgroundColor: kActiveButtonColor,
          child: Icon(
            Icons.chat_bubble,
            size: 15,
            color: kWhiteColor,
          ),
        ));
  }
}
