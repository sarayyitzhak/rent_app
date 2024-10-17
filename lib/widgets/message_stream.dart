import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/chat.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:rent_app/models/message.dart';
import '../constants.dart';
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

  List<Widget> getMessagesBubbles(List<QueryDocumentSnapshot<Map<String, dynamic>>> messages){
    var prevMessageSender;
    DateTime prevMessageTime = DateTime.now();
    List<Widget> messageBubbles = [];
    bool first = true;
    for (var message in messages!) {
      var messageData = message.data();
      Message newMessage = mapAsMessage(messageData);
      if (first) {
        messageBubbles.add(DateChip(date: newMessage.sentAt));
        first = false;
      } else {
        if (newMessage.sentAt.day != prevMessageTime.day) {
          messageBubbles.add(DateChip(date: newMessage.sentAt));
        }
      }
      if (prevMessageSender == newMessage.sender) {
        var last = (messageBubbles.last.runtimeType == MessageBubble
            ? messageBubbles.last
            : messageBubbles.elementAt(messageBubbles.length - 2))
        as MessageBubble;
        if (prevMessageTime.day == newMessage.sentAt.day) {
          last.tail = false;
          if (prevMessageTime.hour == newMessage.sentAt.hour &&
              prevMessageTime.minute == newMessage.sentAt.minute) {
            last.showTime = false;
          }
        }
      }
      messageBubbles.add(MessageBubble(
        message: newMessage,
        isMe: userIdx == newMessage.sender,
      ));
      prevMessageSender = newMessage.sender;
      prevMessageTime = newMessage.sentAt;
    }
    return messageBubbles;
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
          var messageBubbles = getMessagesBubbles(messages!);
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