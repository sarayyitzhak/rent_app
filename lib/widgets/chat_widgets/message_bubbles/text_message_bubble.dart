import 'package:flutter/material.dart';
import 'package:rent_app/widgets/chat_widgets/message_time.dart';
import '../../../models/chat.dart';
import '../../../models/message.dart';

class TextMessageBubble extends StatelessWidget {
  final Chat chat;
  final Message message;
  final bool isMe;
  final bool tail;
  final MessageReadNotifier messageReadNotifier;

  const TextMessageBubble(
      {super.key,
      required this.chat,
      required this.message,
      required this.isMe,
      required this.tail,
      required this.messageReadNotifier});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
          ),
          child: Text(
            message.text ?? '',
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        isMe ? const SizedBox(width: 4) : Container(),
        MessageTime(
          chat: chat,
          message: message,
          isMe: isMe,
          messageReadNotifier: messageReadNotifier,
        )
      ],
    );
  }
}
