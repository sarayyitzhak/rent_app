import 'dart:async';

import 'package:rent_app/models/user.dart';
import 'package:rent_app/utils.dart';

import '../../constants.dart';
import '../../globals.dart';
import '../../models/chat.dart';
import 'package:flutter/material.dart';

import '../../models/message.dart';
import '../../models/message_type.dart';
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

  @override
  void initState() {
    super.initState();

    _fetchOtherParticipantData();
  }

  void _fetchOtherParticipantData() async {
    bool isUserIndex0 = widget.chat.participantInfo0.uid == userDetails.docRef.id;
    var otherParticipantUid = isUserIndex0 ? widget.chat.participantInfo1.uid : widget.chat.participantInfo0.uid;
    UserDetails otherParticipant = await getUserByID(otherParticipantUid);

    setState(() {
      _otherParticipantName = otherParticipant.name;
    });
  }

  String _getLastMessageText() {
    if (widget.chat.lastMessageContent is int) {
      MessageType messageType = numToMessageType(widget.chat.lastMessageContent);
      if (messageType == MessageType.IMAGE) {
        return 'תמונה';
      } else if (messageType == MessageType.VOICE_RECORD) {
        return 'הקלטה קולית';
      }
      return '';
    } else {
      return widget.chat.lastMessageContent;
    }
  }

  int _getUnreadMessageCount() {
    bool isUserIndex0 = widget.chat.participantInfo0.uid == userDetails.docRef.id;
    return isUserIndex0 ? widget.chat.participantInfo0.unreadMessages : widget.chat.participantInfo1.unreadMessages;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ChatScreen.id, arguments: ChatScreenArguments(widget.chat)),
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: kActiveButtonColor)),
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
                    _getLastMessageText(),
                    style: kSmallBlackTextStyle,
                  ),
                ],
              ),
              Column(
                children: [
                  Text(getHourMinuteFormat(widget.chat.lastMessageTime)),
                  if (_getUnreadMessageCount() > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_getUnreadMessageCount()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ],
          )),
    );
  }
}
