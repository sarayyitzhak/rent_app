
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:rent_app/db/chatDB.dart';
import 'package:rent_app/db/messageDB.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';

import '../constants.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;
int messageId = 0;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  ChatScreen({super.key});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  String messageText = '';
  late int userIndex;
  late Chat chat;
  late DocumentReference chatDoc;
  late List<String> participantsNames = ['', ''];


  @override
  void initState() {
    super.initState();
  }

  void getUserIndex(Chat chat) { // to know that he is the sender
    userIndex =  chat.participants!.indexOf(userDetails.userReference.path);
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as ChatScreenArguments;
    chat = arg.chat;
    getUserIndex(chat);
    chatDoc = _firestore.collection('chats').doc(chat.cloudKey);

    final isar = Provider.of<Isar>(context);
    return Scaffold(
      appBar: CustomAppBar(title: 'chat name'),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(chat: chat, userIdx: userIndex, chatDoc: chatDoc),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      chatDoc.collection('messages').add({
                        'sender': userIndex,
                        'text': messageText,
                        'sentAt': Timestamp.now(),
                        'read': false
                      });
                      final message = Message()..sender = userIndex..text = messageText..sentAt = Timestamp.now().toDate()..read = false;
                      chat.messages.add(message);
                      isar.writeTxn(() async {
                        await isar.messages.put(message); // check if needed
                        await chat.messages.save();
                      });
                      // messageId++;
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  Chat chat;
  int userIdx;
  DocumentReference chatDoc;
  MessagesStream({super.key, required this.chat, required this.userIdx, required this.chatDoc});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        // stream: chat.messages != null ? chat.messages.watch() : Stream.value([]),
        stream: chatDoc.collection('messages').orderBy('sentAt').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print(snapshot.data);
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: kPastelYellow,
              ),
            );
          }
          final messages = snapshot.data?.docs.reversed;
          List<MessageBubble> messageBubbles = [];
          for (var message in messages!) {
            var massageData = message.data() as Map<String, dynamic>;
            final messageText = massageData['text'];
            final messageSender = massageData['sender'];
            final currentUser = userIdx;
            final messageBubble = MessageBubble(
              text: messageText,
              isMe: currentUser == messageSender,
            );
            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              children: messageBubbles,
            ),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  MessageBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Material(
            borderRadius: isMe
                ? kUserSideBubbleEn : kContactSideBubbleEn,
            elevation: 5,
            color: isMe ? kActiveButtonColor : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: isMe ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class ChatScreenArguments {
  final Chat chat;
  ChatScreenArguments(this.chat);
}

