import 'dart:async';

import '../../constants.dart';
import '../../globals.dart';
import '../../models/chat.dart';
import 'package:flutter/material.dart';

import '../../models/message.dart';
import '../../screens/chat_screen.dart';
import '../../services/cloud_services.dart';

class ChatCard extends StatefulWidget {
  final Chat chat;

  const ChatCard({super.key, required this.chat});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  String? _otherParticipantName;
  Message? _lastMessage;
  int _unreadMessages = 0;

  StreamSubscription? _lastMessageSubscription;

  @override
  void initState() {
    super.initState();

    _fetchOtherParticipantData();
    _fetchUnreadMessagesCount();

    _lastMessageSubscription = getLastMessageStream(widget.chat.docRef).listen((message) {
      setState(() {
        _lastMessage = message;
      });
    });
  }

  void _fetchOtherParticipantData() async {
    String otherParticipantName = await getOtherParticipantName(widget.chat);

    setState(() {
      _otherParticipantName = otherParticipantName;
    });
  }

  Future<void> _fetchUnreadMessagesCount() async {
    int? userIndex = widget.chat.participants[userDetails.docRef.id]?.index;
    DateTime? fromDate = widget.chat.participants[userDetails.docRef.id]?.lastMessageSeenTime;

    if (userIndex != null && fromDate != null) {
      int unreadMessages = await getUnreadMessagesCount(widget.chat.docRef, userIndex, fromDate);

      setState(() {
        _unreadMessages = unreadMessages;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _lastMessageSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ChatScreen.id,
          arguments: ChatScreenArguments(widget.chat, _otherParticipantName)),
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kActiveButtonColor)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _otherParticipantName ?? '',
                    style: kBlackHeaderTextStyle,
                  ),
                  Text(
                    _lastMessage?.text ?? '',
                    style: kSmallBlackTextStyle,
                  ),
                ],
              ),
              Column(
                children: [
                  Text(_lastMessage?.sentAtAsString() ?? ''),
                  if (_unreadMessages > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_unreadMessages',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ],
          )),
    );
  }
}