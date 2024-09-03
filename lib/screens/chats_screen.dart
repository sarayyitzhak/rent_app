import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/db/chatDB.dart';
import 'package:rent_app/screens/chat_screen.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../db/messageDB.dart';
import '../db/chatDB.dart';
import '../main.dart';
import '../services/firebase_services.dart';

class ChatsScreen extends StatelessWidget {
  static String id = 'chats_screen.dart';
  ChatsScreen({super.key});
  late int chatsCount;

  Future<int> getChatsCount(Isar isar) async {
    return await isar.chats.count();
  }

  @override
  Widget build(BuildContext context) {
    final isar = Provider.of<Isar>(context);
    var localization = AppLocalizations.of(context)!;
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(title: localization.chats, isBackButton: false),
        body: FutureBuilder<int>(
          future: getChatsCount(isar),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading chats count'));
            } else if (snapshot.hasData) {
              int chatsCount = snapshot.data!;
              return ListView.builder(
                itemCount: chatsCount,
                itemBuilder: (context, index) {
                  return chatCard(index: index, isar: isar);
                },
              );
            } else {
              return Center(child: Text('No chats available'));
            }
          },
        ),
      ),
    );
  }
}

class chatCard extends StatefulWidget {
  int index;
  Isar isar;
  chatCard({super.key, required this.index, required this.isar});

  @override
  State<chatCard> createState() => _chatCardState();
}

class _chatCardState extends State<chatCard> {
  Chat? chat;
  Message? lastMessage;

  Future<Message?> getChat(int index) async {
    chat = await widget.isar.chats.get(index);
    lastMessage = chat?.messages.last;
    return lastMessage;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ChatScreen.id, arguments: ChatScreenArguments(chat!)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // color: kBlue,
          border: Border.all(color: kActiveButtonColor)
        ),
        child: FutureBuilder(
            future: getChat(widget.index + 1),
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lastMessage!.senderName, style: kBlackHeaderTextStyle,),
                        Text(lastMessage!.text, style: kSmallBlackTextStyle,),
                      ],
                    ),
                    Text('${lastMessage!.sentAt.hour}:${lastMessage!.sentAt.minute}'),
                  ],
                );
              }
              return Text('no messages');
            },
        ),
      ),
    );
  }
}
