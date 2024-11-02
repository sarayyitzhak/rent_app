import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/chat.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/widgets/chat_bottom_send_bar.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import '../models/message.dart';
import '../services/cloud_services.dart';
import '../utils.dart';
import '../widgets/chat_widgets/date_bubble.dart';
import '../widgets/chat_widgets/message_bubbles/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  final ChatScreenArguments args;
  const ChatScreen(this.args, {super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  late Chat chat;

  String? _personName;
  int _userIndex = -1;
  final List<DocumentSnapshot> _messages = [];
  bool _loading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  StreamSubscription? _newMessagesSubscription;

  @override
  void initState() {
    super.initState();
    isChatScreenActive = true;

    setState(() {
      chat = widget.args.chat;
      _personName = widget.args.otherParticipantName;
      _userIndex = chat.participants[userDetails.userReference.id]?.index ?? -1;
    });

    _fetchMessages(20);
    _fetchNewMessages();

    if (chat.participants[userDetails.userReference.id]!.lastMessageSeenTime != chat.lastMessageSentAt) {
      updateUserLastMessageSeenTime(chat.docRef, chat.lastMessageSentAt);
    }
  }

  void _fetchMessages(int limit) async {
    if (_loading || !_hasMore) return;

    _loading = true;

    QuerySnapshot querySnapshot = await getHistoricalMessages(chat.docRef, limit, _lastDocument);
    List<DocumentSnapshot> newDocuments = querySnapshot.docs;

    if (newDocuments.length < limit) {
      _hasMore = false;
    }

    if (newDocuments.isNotEmpty) {
      _lastDocument = newDocuments.last;

      setState(() {
        _messages.addAll(newDocuments);
      });
    }

    _loading = false;
  }

  void _fetchNewMessages() async {
    _newMessagesSubscription = getNewMessagesStream(chat.docRef).listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          setState(() {
            _messages.insert(0, change.doc);
          });

          Map<String, dynamic> messageData = change.doc.data() as Map<String, dynamic>;
          Message newMessage = mapAsMessage(messageData, change.doc.reference);
          updateUserLastMessageSeenTime(chat.docRef, newMessage.sentAt);
        }
      }
    });
  }

  List<Widget> _getBubbles() {
    Message? lastMessage;
    List<Widget> bubbles = [];
    for (var message in _messages) {
      Map<String, dynamic> messageData = message.data() as Map<String, dynamic>;
      Message newMessage = mapAsMessage(messageData, message.reference);
      int daysDifference = lastMessage != null ? getDaysDifference(newMessage.sentAt, lastMessage.sentAt) : 0;
      if (daysDifference != 0) {
        bubbles.add(DateBubble(dateTime: lastMessage!.sentAt));
      }

      MessageBubble messageBubble = MessageBubble(
        chat: chat,
        message: newMessage,
        isMe: _userIndex == newMessage.sender,
      );

      if (lastMessage?.sender == newMessage.sender && daysDifference == 0) {
        messageBubble.tail = false;
      }
      if (lastMessage?.sender != newMessage.sender && daysDifference == 0) {
        messageBubble.bottomMargin = 10;
      }
      bubbles.add(messageBubble);
      lastMessage = newMessage;
    }
    if (!_hasMore) {
      bubbles.add(DateBubble(dateTime: lastMessage!.sentAt));
    }
    return bubbles;
  }

  @override
  void dispose() {
    super.dispose();
    isChatScreenActive = false;
    _newMessagesSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: _personName ?? ''),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !_loading) {
                  _fetchMessages(20);
                }
                return false;
              },
              child: Expanded(
                child: ListView(
                  reverse: true,
                  children: _getBubbles(),
                ),
              ),
            ),
            Container(
              // decoration: kMessageContainerDecoration,
              color: Colors.grey[300],
              padding: const EdgeInsets.only(right: 8),
              child: ChatBottomSendBar(chat: chat, userIdx: _userIndex,),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreenArguments {
  final Chat chat;
  final String? otherParticipantName;
  ChatScreenArguments(this.chat, this.otherParticipantName);
}
