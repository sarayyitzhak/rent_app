import 'dart:async';

import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../services/cloud_services.dart';

class MessageTime extends StatefulWidget {
  Chat chat;
  final Message message;
  final bool isMe;

  MessageTime({super.key, required this.chat, required this.message, required this.isMe});

  @override
  State<MessageTime> createState() => _MessageTimeState();
}

class _MessageTimeState extends State<MessageTime> {

  StreamSubscription? _chatSubscription;

  bool isMessageRead() {
    for (String uid in widget.chat.participants.keys) {
      if (uid != userDetails.userReference.id) {
        DateTime lastMessageSeenTime = widget.chat.participants[uid]!.lastMessageSeenTime;
        return widget.message.sentAt.isBefore(lastMessageSeenTime);
      }
    }
    return false;
  }

  Icon buildReadIcon() {
    bool messageRead = isMessageRead();
    return Icon(
      messageRead ? Icons.done_all : Icons.done,
      color: messageRead ? Colors.cyan[300] : Colors.grey[300],
      size: 18
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.isMe && !isMessageRead()) {
      _chatSubscription = getChatStream(widget.chat.docRef).listen((chat) {
        setState(() {
          widget.chat = chat;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    _chatSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        widget.isMe ? buildReadIcon() : Container(),
        const SizedBox(width: 4),
        Text(
          widget.message.sentAtAsString(),
          style: TextStyle(
            color: Colors.grey[widget.isMe ? 300 : 700],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
