import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:rent_app/models/chat.dart';
import 'package:rent_app/models/message_type.dart';
import 'package:rent_app/models/message.dart';
import '../message_time.dart';
import 'image_message_bubble.dart';
import 'item_message_bubble.dart';
import 'record_message_bubble.dart';
import 'text_message_bubble.dart';

class MessageBubble extends StatelessWidget {
  final Chat chat;
  final Message message;
  final bool isMe;
  final double topMargin;
  final double bottomMargin;
  final MessageReadNotifier messageReadNotifier;
  final MessageTailsNotifier messageTailsNotifier;

  const MessageBubble(
      {super.key,
      required this.chat,
      required this.message,
      required this.isMe,
      required this.topMargin,
      required this.bottomMargin,
      required this.messageReadNotifier,
      required this.messageTailsNotifier});

  Widget createBubbleByType() {
    if (message.type.index == MessageType.TEXT.index) {
      return TextMessageBubble(
        chat: chat,
        message: message,
        isMe: isMe,
        messageReadNotifier: messageReadNotifier,
      );
    } else if (MessageType.VOICE_RECORD.index == message.type.index) {
      return RecordMessageBubble(
        chat: chat,
        message: message,
        isMe: isMe,
        messageReadNotifier: messageReadNotifier,
      );
    } else if (MessageType.IMAGE.index == message.type.index) {
      return ImageMessageBubble(
        chat: chat,
        message: message,
        isMe: isMe,
        messageReadNotifier: messageReadNotifier,
      );
    } else if (MessageType.ITEM.index == message.type.index) {
      return ItemMessageBubble(
        chat: chat,
        message: message,
        isMe: isMe,
        messageReadNotifier: messageReadNotifier,
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        ListenableBuilder(
          listenable: messageTailsNotifier,
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(left: 10, right: 10, bottom: bottomMargin, top: topMargin),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadiusDirectional.only(
                    topStart: const Radius.circular(15),
                    topEnd: const Radius.circular(15),
                    bottomEnd: Radius.circular(!isMe && messageTailsNotifier.contains(message.docRef.id) ? 0 : 15),
                    bottomStart: Radius.circular(isMe && messageTailsNotifier.contains(message.docRef.id) ? 0 : 15)),
              ),
              child: child,
            );
          },
          child: createBubbleByType(),
        ),
      ],
    );
  }
}

class MessageTailsNotifier extends ChangeNotifier {
  Set<String> messageIds = {};

  void add(String messageId) {
    messageIds.add(messageId);
  }

  void remove(String messageId) {
    messageIds.remove(messageId);
    notifyListeners();
  }

  bool contains(String messageId) {
    return messageIds.contains(messageId);
  }
}
