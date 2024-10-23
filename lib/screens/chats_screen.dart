import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/models/chat.dart';
import 'package:rent_app/screens/chat_screen.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/cloud_services.dart';

class ChatsScreen extends StatelessWidget {
  static String id = 'chats_screen.dart';

  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    return SafeArea(
      child: Scaffold(
          appBar: CustomAppBar(title: localization.chats, isBackButton: false),
          body: StreamBuilder(
              stream: getUserChatsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: Text(
                    localization.noChatsYet,
                    style: kBlackHeaderTextStyle,
                  ));
                }
                List<Chat> chats = snapshot.data!;
                List<ChatCard> chatCards = [];
                for (Chat chat in chats) {
                  chatCards.add(ChatCard(chat: chat));
                }
                return ListView(
                  // reverse: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  children: chatCards,
                );
              })),
    );
  }
}

class ChatCard extends StatefulWidget {
  final Chat chat;

  const ChatCard({super.key, required this.chat});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  String? _otherParticipantName;
  Message? _lastMessage;

  @override
  void initState() {
    super.initState();
    _fetchOtherParticipantData();
    _fetchLastMessage();
  }

  void _fetchOtherParticipantData() async {
    for (String uid in widget.chat.participants.keys) {
      if (uid != userDetails.userReference.id) {
        UserDetails otherParticipantUser = await getUserDetailsByUid(uid);
        setState(() {
          _otherParticipantName = otherParticipantUser.name;
        });
      }
    }
  }

  void _fetchLastMessage() async {
    Message? lastMessage = await getLastMessage(widget.chat.docRef);
    setState(() {
      _lastMessage = lastMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ChatScreen.id,
          arguments: ChatScreenArguments(widget.chat, _otherParticipantName)),
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kActiveButtonColor)),
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
                    _lastMessage?.text ?? '',
                    style: kSmallBlackTextStyle,
                  ),
                ],
              ),
              Text(_lastMessage?.sentAtAsString() ?? ''),
            ],
          )),
    );
  }
}
