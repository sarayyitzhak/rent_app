import 'package:rent_app/models/user.dart';
import 'package:rent_app/utils.dart';

import '../../constants.dart';
import '../../globals.dart';
import '../../models/chat.dart';
import 'package:flutter/material.dart';

import '../../models/message_type.dart';
import '../../screens/chat_screen.dart';
import '../../services/cloud_services.dart';
import '../cached_image.dart';

class ChatCard extends StatefulWidget {
  final Chat chat;

  const ChatCard({super.key, required this.chat});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  UserDetails? _participantUser;

  void _fetchParticipantUser() async {
    bool isUserIndex0 =
        widget.chat.participantInfo0.uid == userDetails.docRef.id;
    var otherParticipantUid = isUserIndex0
        ? widget.chat.participantInfo1.uid
        : widget.chat.participantInfo0.uid;
    UserDetails participantUser = await getUserByID(otherParticipantUid);

    setState(() {
      _participantUser = participantUser;
    });
  }

  String _getLastMessageText() {
    if (widget.chat.lastMessageContent is int) {
      MessageType messageType =
          numToMessageType(widget.chat.lastMessageContent);
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
    bool isUserIndex0 =
        widget.chat.participantInfo0.uid == userDetails.docRef.id;
    return isUserIndex0
        ? widget.chat.participantInfo0.unreadMessages
        : widget.chat.participantInfo1.unreadMessages;
  }

  @override
  void initState() {
    super.initState();

    _fetchParticipantUser();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ChatScreen.id,
          arguments: ChatScreenArguments(widget.chat)),
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kActiveButtonColor)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CachedImage(
                    width: 50,
                    height: 50,
                    imageRef: _participantUser != null
                        ? getUserImageRef(
                            _participantUser!.docRef, _participantUser!.photoID)
                        : null,
                    borderRadius: BorderRadius.circular(100),
                    errorIcon: Icons.person,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _participantUser?.name ?? '',
                        style: kBlackHeaderTextStyle,
                      ),
                      Text(
                        _getLastMessageText(),
                        style: kSmallBlackTextStyle,
                      ),
                    ],
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
