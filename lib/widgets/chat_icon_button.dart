import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/models/chat.dart';
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
  late List<DocumentReference> participants;

  void goToChat(Chat? chat) async {
    Navigator.pushNamed(context, ChatScreen.id, arguments: ChatScreenArguments(chat!));
  }

  @override
  Widget build(BuildContext context) {
    // final isar = Provider.of<Isar>(context);
    return IconButton(
        padding: const EdgeInsets.all(3),
        constraints: const BoxConstraints(),
        style: const ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
        ),
        onPressed: () async {
          Chat? chat = await getChat(widget.item.contactUser);
          Chat newChat;
          chat ??= await createNewChat(widget.item.contactUser);
          DocumentSnapshot<Object?> contactUser = await widget.item.contactUser.get();
          Map<String, dynamic> contactUserData = contactUser.data() as Map<String, dynamic>;
          chat.otherParticipantName = contactUserData['fullName'];
          goToChat(chat);
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
