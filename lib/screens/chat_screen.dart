import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/chat.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;
int messageId = 0;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  const ChatScreen({super.key});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  String messageText = '';
  late int userIndex;
  late Chat chat;
  late String? personName;
  late DocumentReference chatDoc;
  late List<String> participantsNames = ['', ''];
  bool showMic = true;

  Future<void> sendPushNotification(String token, String message) async {
    const String serverToken =
        kGoogleApiKey; // Get this from your Firebase Console

    final response = await http.post(
        Uri.parse(
            'fcm.googleapis.com/v1/projects/myproject-b5ae1/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken',
        },
        body: jsonEncode(<String, dynamic>{
          'message': {
            'topic': token,
            'notification': {'title': 'New message', 'body': message},
            'data': {'story_id': 'story_12345'}
          }
        }));

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void getUserIndex(Chat chat) {
    // to know that he is the sender
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
    chatDoc = chat.cloudKey;
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
            MessagesStream(
                chat: chat, userIdx: userIndex, chatDoc: chat.cloudKey),
            Container(
              // decoration: kMessageContainerDecoration,
              color: Colors.grey[300],
              // height: 60,
              padding: const EdgeInsets.only(
                right: 8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white60,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: messageTextController,
                              textInputAction: TextInputAction.newline,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              minLines: 1,
                              maxLines: 3,
                              onChanged: (value) {
                                messageText = value;
                                setState(() {
                                  showMic = false;
                                  if (value.isEmpty) {
                                    showMic = true;
                                  }
                                });
                              },
                              decoration: kMessageTextFieldDecoration,
                            ),
                          ),
                          showMic
                              ? IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.mic_none_outlined,
                                    color: kBlackColor,
                                  ),
                                  padding: EdgeInsets.zero,
                                )
                              : const SizedBox(),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.camera_alt_outlined,
                              color: kBlackColor,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 0),
                    child: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: IconButton(
                          onPressed: () {
                            if (messageTextController.text.isNotEmpty) {
                              messageTextController.clear();
                              Timestamp sentAt = Timestamp.now(); 
                              chat.cloudKey.collection('messages').add({
                                'sender': userIndex,
                                'text': messageText,
                                'sentAt': sentAt,
                                'read': false
                              });
                              chatDoc.update({'lastMessageSentAt': sentAt});
                              // if (chat.otherParticipantToken != null) {
                              //   sendPushNotification(chat.otherParticipantToken.toString(), messageText);
                              // }
                            }
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          )),
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
  MessagesStream(
      {super.key,
      required this.chat,
      required this.userIdx,
      required this.chatDoc});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: chatDoc.collection('messages').orderBy('sentAt').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print(snapshot.data);
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: kPastelYellow,
              ),
            );
          }
          final messages = snapshot.data?.docs;
          var prevMessageSender;
          DateTime prevMessageTime = DateTime.now();
          List<Widget> messageBubbles = [];
          bool first = true;
          for (var message in messages!) {
            var massageData = message.data();
            final messageText = massageData['text'];
            final messageSender = massageData['sender'];
            final messageRead = massageData['read'];
            DateTime messageTime = massageData['sentAt'].toDate();
            if (first) {
              messageBubbles.add(DateChip(date: messageTime));
              first = false;
            } else {
              if (messageTime.day != prevMessageTime.day) {
                messageBubbles.add(DateChip(date: messageTime));
              }
            }
            if (prevMessageSender == messageSender) {
              var last = (messageBubbles.last.runtimeType == MessageBubble
                      ? messageBubbles.last
                      : messageBubbles.elementAt(messageBubbles.length - 2))
                  as MessageBubble;
              if (prevMessageTime.day == messageTime.day) {
                last.tail = false;
                if (prevMessageTime.hour == messageTime.hour &&
                    prevMessageTime.minute == messageTime.minute) {
                  last.sentAt = null;
                }
              }
            }
            final currentUser = userIdx;
            final messageBubble = MessageBubble(
              text: messageText,
              isMe: currentUser == messageSender,
              // firstMessageOfSender: prevMessageSender != messageSender,
              read: messageRead,
              sentAt: messageTime,
            );
            messageBubbles.add(messageBubble);
            prevMessageSender = messageSender;
            prevMessageTime = messageTime;
          }
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

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final bool read;
  DateTime? sentAt;
  bool tail;
  MessageBubble(
      {super.key,
      required this.text,
      required this.isMe,
      /*required this.firstMessageOfSender,*/ required this.read,
      this.sentAt,
      this.tail = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        // isMe ? SizedBox() : Text('${sentAt.hour}:${sentAt.minute}', style: kSmallBlackTextStyle,),
        BubbleSpecialThree(
          text: text,
          isSender: isMe,
          color: isMe ? Colors.blue : Colors.grey[300]!,
          tail: tail,
          sent: isMe ? !read : false,
          seen: isMe ? read : false,
          textStyle: TextStyle(
            color: isMe ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: sentAt == null
              ? Container()
              : Text(
                  '${sentAt?.hour}:${sentAt?.minute}',
                  style: kSmallBlackTextStyle,
                ),
        ),
      ],
    );
  }
}

// class MessageBubble extends StatelessWidget {
// final String text;
// final bool isMe;
// MessageBubble({required this.text, required this.isMe});
//
// @override
// Widget build(BuildContext context) {
// return Padding(
// padding: EdgeInsets.all(10.0),
// child: Column(
// crossAxisAlignment:
// isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
// children: [
// Material(
// borderRadius: isMe
// ? kUserSideBubbleEn : kContactSideBubbleEn,
// elevation: 5,
// color: isMe ? kActiveButtonColor : Colors.white,
// child: Padding(
// padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
// child: Text(
// text,
// style: TextStyle(
// fontSize: 15,
// color: isMe ? Colors.white : Colors.black54,
// ),
// ),
// ),
// ),
// ],
// ),
// );
// }
// }

class ChatScreenArguments {
  final Chat chat;
  ChatScreenArguments(this.chat);
}
