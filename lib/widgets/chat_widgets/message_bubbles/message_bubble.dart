import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:rent_app/models/message_type.dart';
import 'package:rent_app/models/message.dart';
import 'image_message_bubble.dart';
import 'item_message_bubble.dart';
import 'record_message_bubble.dart';
import 'text_message_bubble.dart';


class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;
  bool tail;
  double bottomMargin;

  MessageBubble({super.key, required this.message, required this.isMe, this.tail = true, this.bottomMargin = 2});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {

  Widget createBubbleByType(){
    if(widget.message.type.index == MessageType.TEXT.index){
      return TextMessageBubble(message: widget.message, isMe: widget.isMe, tail: widget.tail);
    } else if(MessageType.VOICE_RECORD.index == widget.message.type.index){
      return RecordMessageBubble(message: widget.message, isMe: widget.isMe, tail: widget.tail);
    } else if(MessageType.IMAGE.index == widget.message.type.index){
      return ImageMessageBubble(message: widget.message, isMe: widget.isMe, tail: widget.tail);
    } else if(MessageType.ITEM.index == widget.message.type.index){
      return ItemMessageBubble(message: widget.message, isMe: widget.isMe, tail: widget.tail);
    }
    else{
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.only(left: 10, right: 10, bottom: widget.bottomMargin),
          // margin: EdgeInsets.symmetric(horizontal: 10, vertical: widget.verticalMargin),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.isMe ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadiusDirectional.only(
                topStart: const Radius.circular(20),
                topEnd: const Radius.circular(20),
                bottomEnd: Radius.circular(!widget.isMe && widget.tail ? 0 : 20),
                bottomStart: Radius.circular(widget.isMe && widget.tail ? 0 : 20)
            ),
          ),
          child: createBubbleByType()
        ),
      ],
    );
  }
}