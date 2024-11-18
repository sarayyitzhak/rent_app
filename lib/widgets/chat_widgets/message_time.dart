import 'package:flutter/material.dart';

import '../../models/chat.dart';
import '../../models/message.dart';
import '../../utils.dart';

class MessageTime extends StatelessWidget {
  final Chat chat;
  final Message message;
  final bool isMe;
  final MessageReadNotifier messageReadNotifier;

  const MessageTime(
      {super.key, required this.chat, required this.message, required this.isMe, required this.messageReadNotifier});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isMe)
          ListenableBuilder(
            listenable: messageReadNotifier,
            builder: (context, child) {
              bool messageRead = !messageReadNotifier.lastMessageSeenTime.isBefore(message.sentAt);
              return Icon(messageRead ? Icons.done_all : Icons.done,
                  color: messageRead ? Colors.cyan[300] : Colors.grey[300], size: 18);
            },
          ),
        const SizedBox(width: 4),
        Text(
          getHourMinuteFormat(message.sentAt),
          style: TextStyle(
            color: Colors.grey[isMe ? 300 : 700],
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
