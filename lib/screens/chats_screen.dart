import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rent_app/models/chat.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import '../dictionary.dart';
import '../services/cloud_services.dart';
import '../services/query_batch.dart';
import '../widgets/chat_widgets/chat_card.dart';

class ChatsScreen extends StatefulWidget {
  static String id = 'chats_screen.dart';

  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  QueryBatch<Chat> _queryBatch = QueryBatch.empty();
  final Map<String, Chat> _chatMap = {};
  List<Chat> _chats = [];
  bool _loading = false;

  StreamSubscription? _chatsSubscription;

  bool onScroll(ScrollNotification scrollInfo) {
    var currentScroll = scrollInfo.metrics.pixels;
    var maxScroll = scrollInfo.metrics.maxScrollExtent;
    var offset = MediaQuery.of(context).size.height * 0.5;
    if (currentScroll >= (maxScroll - offset) && !_loading) {
      _fetchChats();
    }
    return false;
  }

  void _fetchChatsStream() {
    _loading = true;

    _chatsSubscription = getUserChatsStream().listen((QueryBatch<Chat> queryBatch) {
      if (_chatMap.isEmpty) {
        _queryBatch = queryBatch;
      }

      _updateChatMap(queryBatch.list);
      _updateChats();

      _loading = false;
    });
  }

  Future<void> _fetchChats() async {
    if (_loading || !_queryBatch.hasMore) return;

    _loading = true;

    _queryBatch = await getUserChats(_queryBatch.lastDoc);

    _updateChatMap(_queryBatch.list);
    _updateChats();

    _loading = false;
  }

  void _updateChatMap(List<Chat> chats) {
    for (Chat chat in chats) {
      _chatMap[chat.docRef.id] = chat;
    }
  }

  void _updateChats() {
    List<Chat> chats = _chatMap.values.toList();
    chats.sort((chat1, chat2) => chat2.lastMessageTime.compareTo(chat1.lastMessageTime));

    setState(() {
      _chats = chats;
    });
  }

  @override
  void initState() {
    super.initState();

    _fetchChatsStream();
  }

  @override
  void dispose() {
    super.dispose();

    _chatsSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var localization = Dictionary.getLocalization(context);
    return Scaffold(
      appBar: CustomAppBar(title: localization.chats, isBackButton: false),
      body: NotificationListener<ScrollNotification>(
        onNotification: onScroll,
        child: ListView.builder(
          itemCount: _chats.length,
          itemBuilder: (context, index) => ChatCard(key: ValueKey(_chats[index].docRef.id), chat: _chats[index]),
        ),
      ),
    );
  }
}
