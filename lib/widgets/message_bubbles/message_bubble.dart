import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:rent_app/models/message_type.dart';
import 'package:rent_app/models/message.dart';
import '../../constants.dart';
import 'record_message_bubble.dart';


class MessageBubble extends StatefulWidget {
  Message message;
  final bool isMe;
  bool showTime;
  bool tail;
  MessageBubble({super.key, required this.message, required this.isMe, this.tail = true, this.showTime = true});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {

  Widget createBubbleByType(){
    if(widget.message.type.index == MessageType.TEXT.index){
      return BubbleSpecialThree(
        text: widget.message.text!,
        isSender: widget.isMe,
        color: widget.isMe ? Colors.blue : Colors.grey[300]!,
        tail: widget.tail,
        sent: widget.isMe ? !widget.message.read : false,
        seen: widget.isMe ? widget.message.read : false,
        textStyle: TextStyle(
          color: widget.isMe ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      );
    } else if(MessageType.VOICE_RECORD.index == widget.message.type.index){
      return RecordMessageBubble(message: widget.message, isMe: widget.isMe, tail: widget.tail);
    } else if(MessageType.IMAGE.index == widget.message.type.index){
      return BubbleNormalImage(
        id: widget.message.fileRef!.toString(),
        image: Image.network(widget.message.fileRef!),
        color: widget.isMe ? Colors.blue : Colors.grey[300]!,
        tail: widget.tail,
        sent: widget.isMe ? !widget.message.read : false,
        seen: widget.isMe ? widget.message.read : false,
        // delivered: true,
      );
    }
    else{
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: widget.isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        createBubbleByType(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: widget.showTime
              ? Text(
            widget.message.sentAtAsString(),
            style: kSmallBlackTextStyle,
          ) : Container()
        ),
      ],
    );
  }
}