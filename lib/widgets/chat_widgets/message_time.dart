import 'package:flutter/material.dart';

import '../../models/chat.dart';
import '../../models/message.dart';
import '../../utils.dart';

class MessageTime extends StatefulWidget {
  final Chat chat;
  final Message message;
  final bool isMe;
  final MessageReadNotifier messageReadNotifier;

  const MessageTime(
      {super.key, required this.chat, required this.message, required this.isMe, required this.messageReadNotifier});

  @override
  State<MessageTime> createState() => _MessageTimeState();
}

class _MessageTimeState extends State<MessageTime> {
  late bool _messageRead = false;

  void _onMessageReadChanged() {
    setState(() {
      _messageRead = !widget.messageReadNotifier.lastMessageSeenTime.isBefore(widget.message.sentAt);
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.isMe) {
      _onMessageReadChanged();
      widget.messageReadNotifier.addListener(_onMessageReadChanged);
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (widget.isMe) {
      widget.messageReadNotifier.removeListener(_onMessageReadChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.isMe)
          Icon(_messageRead ? Icons.done_all : Icons.done,
              color: _messageRead ? Colors.cyan[300] : Colors.grey[300], size: 18),
        const SizedBox(width: 4),
        Text(
          getHourMinuteFormat(widget.message.sentAt),
          style: TextStyle(
            color: Colors.grey[widget.isMe ? 300 : 700],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class MessageReadNotifier extends ChangeNotifier {
  late DateTime lastMessageSeenTime;

  void updateLastMessageSeenTime(DateTime lastMessageSeenTime) {
    if (this.lastMessageSeenTime != lastMessageSeenTime) {
      this.lastMessageSeenTime = lastMessageSeenTime;
      notifyListeners();
    }
  }
}
