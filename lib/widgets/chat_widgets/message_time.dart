import 'package:flutter/material.dart';

import '../../models/message.dart';

class MessageTime extends StatefulWidget {
  final Message message;
  final bool isMe;

  const MessageTime({super.key, required this.message, required this.isMe});

  @override
  State<MessageTime> createState() => _MessageTimeState();
}

class _MessageTimeState extends State<MessageTime> {

  Icon buildReadIcon() {
    return Icon(
      widget.message.read ? Icons.done_all : Icons.done,
      color: widget.message.read ? Colors.cyan[300] : Colors.grey[300],
      size: 18
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        widget.isMe
            ? widget.message.read
                ? buildReadIcon()
                : StreamBuilder(
                    stream: widget.message.cloudKey!.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Map<String, dynamic> messageData = snapshot.data?.data() as Map<String, dynamic>;
                        Message message = mapAsMessage(messageData, null);
                        widget.message.read = message.read;
                      }
                      return buildReadIcon();
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
