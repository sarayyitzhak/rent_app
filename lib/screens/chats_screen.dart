import 'dart:async';

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
import '../widgets/chat_widgets/chat_card.dart';

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
                    )
                  );
                }
                List<Chat> chats = snapshot.data!;
                List<ChatCard> chatCards = [];
                for (Chat chat in chats) {
                  chatCards.add(ChatCard(chat: chat));
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  children: chatCards,
                );
              })),
    );
  }
}