import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/chat.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/widgets/chat_bottom_send_bar.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import '../widgets/chat_widgets/message_stream.dart';

late User loggedInUser;
int messageId = 0;

class ChatScreen extends StatelessWidget {
  static const String id = 'chat_screen';
  late int userIndex;
  late Chat chat;
  late String? personName;
  late DocumentReference chatDoc;
  late List<String> participantsNames = ['', ''];
  late String recordingUrl;
  ChatScreen({super.key});


  void getUserIndex(Chat chat) {
    userIndex = chat.participants.indexOf(userDetails.userReference);
  }

  void setMessagesRead() async {
    var unreadMessages = await chat.cloudKey
        .collection('messages')
        .where('read', isEqualTo: false)
        .get();
    for (var unreadMessage in unreadMessages.docs) {
      if (unreadMessage.data()['sender'] != userIndex) {
        unreadMessage.reference.update({'read': true});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final arg =
        ModalRoute.of(context)!.settings.arguments as ChatScreenArguments;
    chat = arg.chat;
    personName = chat.otherParticipantName;
    getUserIndex(chat);
    setMessagesRead();
    // final isar = Provider.of<Isar>(context);
    return Scaffold(
      appBar: CustomAppBar(
          title: personName!.isNotEmpty ? personName.toString() : ''),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(
                chat: chat, userIdx: userIndex, chatDoc: chat.cloudKey),
            Container(
              // decoration: kMessageContainerDecoration,
              color: Colors.grey[300],
              padding: const EdgeInsets.only(right: 8),
              child: ChatBottomSendBar(chat: chat, userIdx: userIndex,),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreenArguments {
  final Chat chat;
  ChatScreenArguments(this.chat);
}
