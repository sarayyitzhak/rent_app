import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/chat.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:rent_app/models/message.dart';
import 'package:rent_app/widgets/chat_widgets/date_bubble.dart';
import '../../constants.dart';
import 'message_bubbles/message_bubble.dart';

class MessagesStream extends StatelessWidget {
  Chat chat;
  int userIdx;
  DocumentReference chatDoc;
  MessagesStream(
      {super.key,
        required this.chat,
        required this.userIdx,
        required this.chatDoc});

  List<Widget> getBubbles(List<QueryDocumentSnapshot<Map<String, dynamic>>> messages){
    Message? lastMessage;
    MessageBubble? lastMessageBubble;
    List<Widget> bubbles = [];
    for (var message in messages) {
      var messageData = message.data();
      Message newMessage = mapAsMessage(messageData);
      int daysDifference = lastMessage != null ? newMessage.sentAt.difference(lastMessage.sentAt).inDays : -1;
      if (daysDifference != 0) {
        bubbles.add(DateBubble(dateTime: newMessage.sentAt));
      }
      if (lastMessage?.sender == newMessage.sender && daysDifference <= 0) {
        lastMessageBubble?.tail = false;
      }
      if (lastMessage?.sender != newMessage.sender && daysDifference <= 0) {
        lastMessageBubble?.bottomMargin = 10;
      }
      lastMessageBubble = MessageBubble(
        message: newMessage,
        isMe: userIdx == newMessage.sender,
      );
      bubbles.add(lastMessageBubble);
      lastMessage = newMessage;
    }
    return bubbles;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: chatDoc.collection('messages').orderBy('sentAt').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: kPastelYellow,
              ),
            );
          }
          final messages = snapshot.data?.docs;
          var messageBubbles = getBubbles(messages!);
          return Expanded(
            child: ListView(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
              children: messageBubbles.reversed.toList(),
            ),
          );
        });
  }
}