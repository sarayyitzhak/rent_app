import 'dart:async';

import '../../constants.dart';
import '../../main.dart';
import '../../models/chat.dart';
import 'package:flutter/material.dart';

import '../../models/message.dart';
import '../../models/user.dart';
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

  StreamSubscription? _lastMessageSubscription;

  @override
  void initState() {
    super.initState();

    _fetchOtherParticipantData();

    _lastMessageSubscription = getLastMessageStream(widget.chat.docRef).listen((message) {
      setState(() {
        _lastMessage = message;
      });
    });
  }

  void _fetchOtherParticipantData() async {
    setState(() async {
      _otherParticipantName = await getOtherParticipantName(widget.chat);
    });
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
              Text(_lastMessage?.sentAtAsString() ?? ''),
            ],
          )),
    );
  }
}