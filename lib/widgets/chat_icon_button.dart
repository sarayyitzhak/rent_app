
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:rent_app/models/chat.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/screens/chat_screen.dart';
import '../constants.dart';

import '../models/item.dart';

class ChatIconButton extends StatefulWidget {
  Item item;
  ChatIconButton({super.key, required this.item});

  @override
  State<ChatIconButton> createState() => _ChatIconButtonState();
}

class _ChatIconButtonState extends State<ChatIconButton> {
  final _firestore = FirebaseFirestore.instance;
  late List<DocumentReference> participants;

  void goToChat(Chat? chat) async {
    Navigator.pushNamed(context, ChatScreen.id, arguments: ChatScreenArguments(chat!));
  }

  Future<Chat> createNewChat(Isar isar) async {
    DocumentReference chatDoc = _firestore.collection('chats').doc();
    Chat chat = Chat(participants: [userDetails.userReference, widget.item.contactUser], cloudKey: chatDoc);
    userDetails.userReference.update({
      'chats': FieldValue.arrayUnion([chatDoc])
    });
    widget.item.contactUser.update({
      'chats': FieldValue.arrayUnion([chatDoc])
    });
    userDetails.chats.add(chatDoc);
    chatDoc.set({
      'participants': [userDetails.userReference, widget.item.contactUser],
    });
    chatDoc.collection('messages').add({//do it after first message is sent
      'sender': 1,
      'text': 'hi how are you',
      'sentAt': Timestamp.now(),
      'read': true,
    });
    // Chat chat = Chat()..participants = participants.map((p) => p.path).toList()..cloudKey = chatDoc.id;
    // await isar.writeTxn(() async {
    //   await isar.chats.put(chat);
    // });
    return chat;
  }

  Future<Chat?> getChat() async {
    var usersChats = await _firestore.collection('chats').where('participants', arrayContains: userDetails.userReference).get();
    for(var chat in usersChats.docs){
      Map<String, dynamic> chatData = chat.data();
      List<DocumentReference> participants = (chatData['participants'] as List<dynamic>).map((e) => e as DocumentReference).toList();
      if(participants[0] == widget.item.contactUser || participants[1] == widget.item.contactUser){
        return Chat(participants: participants, cloudKey: chat.reference);
      }
    }
    return null;


     // var c = await isar.chats.filter().participantsElementContains(userDetails.userReference.path).participantsElementContains(widget.item.contactUser.path).findFirst();
     // return c;

    // List participants = await isar.chats.filter().participantsElementContains(widget.item.contactUser.id).findAll();//user is in the participants
    // if(participants.isNotEmpty){
      //go to chat
    // } else {
      //create chat
    // }
    // CollectionReference chatsRef = _firestore.collection('chats'); // maybe better somehow
    // var chat = chatsRef.where('participants', arrayContains: [userDetails.userReference, widget.item.contactUser]);
    //
    // for(DocumentReference chat in userDetails.chats){
    //   var chatDoc = await chat.get();
    //   var chatData = chatDoc.data() as Map<String, dynamic>;
    //   participants = chatData['participants'];
    //   if(participants.contains(widget.item.contactUser)){
    //     return chatData;
    //   }
    // }
    // return null;

  }

  @override
  Widget build(BuildContext context) {
    final isar = Provider.of<Isar>(context);

    return IconButton(
        padding: const EdgeInsets.all(3),
        constraints: const BoxConstraints(),
        style: const ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
        ),
        onPressed: () async {
          Chat? chat = await getChat();
          Chat newChat;
          chat ??= await createNewChat(isar);
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
