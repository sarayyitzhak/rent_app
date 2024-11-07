import 'dart:async';

import 'package:flutter/material.dart';

import 'package:rent_app/globals.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../services/cloud_services.dart';

class MessageTime extends StatefulWidget {
  final Chat chat;
  final Message message;
  final bool isMe;

  const MessageTime(
      {super.key,
      required this.chat,
      required this.message,
      required this.isMe});

  @override
  State<MessageTime> createState() => _MessageTimeState();
}

class _MessageTimeState extends State<MessageTime> {

  bool isMessageRead(Chat chat) {
    for (String uid in chat.participants.keys) {
      if (uid != userDetails.docRef.id) {
        DateTime lastMessageSeenTime =
            chat.participants[uid]!.lastMessageSeenTime;
        return !lastMessageSeenTime.isBefore(widget.message.sentAt);
      }
    }
    return false;
  }

  Icon buildReadIcon(bool messageRead) {
    return Icon(
        messageRead ? Icons.done_all : Icons.done,
        color: messageRead ? Colors.cyan[300] : Colors.grey[300],
        size: 18
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        widget.isMe
            ? isMessageRead(widget.chat)
                ? buildReadIcon(true)
                : StreamBuilder(
                    stream: getChatStream(widget.chat.docRef),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return buildReadIcon(isMessageRead(snapshot.data!));
                      }
                      return buildReadIcon(false);
                    })
            : Container(),
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
