import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rent_app/models/chat.dart';
import 'package:rent_app/globals.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/widgets/chat_bottom_send_bar.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import '../models/message.dart';
import '../models/participant_data.dart';
import '../services/cloud_services.dart';
import '../services/query_batch.dart';
import '../utils.dart';
import '../widgets/chat_widgets/date_bubble.dart';
import '../widgets/chat_widgets/message_bubbles/message_bubble.dart';
import '../widgets/chat_widgets/message_time.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  final ChatScreenArguments args;

  const ChatScreen(this.args, {super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Chat chat;
  late bool _isUserIndex0;
  late ParticipantData _participantInfo;
  UserDetails? _participantUser;

  QueryBatch<Message> _queryBatch = QueryBatch.empty();
  final Map<String, Message> _messageMap = {};
  List<Widget> _bubbles = [];
  bool _loading = false;

  final MessageReadNotifier messageReadNotifier = MessageReadNotifier();

  StreamSubscription? _chatSubscription;
  StreamSubscription? _messagesSubscription;

  bool onScroll(ScrollNotification scrollInfo) {
    var currentScroll = scrollInfo.metrics.pixels;
    var maxScroll = scrollInfo.metrics.maxScrollExtent;
    var offset = MediaQuery.of(context).size.height * 0.5;
    if (currentScroll >= (maxScroll - offset) && !_loading) {
      _fetchMessages();
    }
    return false;
  }

  Future<void> _fetchParticipantUser() async {
    UserDetails participantUser = await getUserByID(_participantInfo.uid);

    setState(() {
      _participantUser = participantUser;
    });
  }

  void _fetchChatStream() {
    _chatSubscription = getChatStream(chat.docRef).listen((Chat chat) {
      _checkAndUpdateUserInfo(chat);

      ParticipantData participantData = _isUserIndex0 ? chat.participantInfo1 : chat.participantInfo0;
      messageReadNotifier.updateLastMessageSeenTime(participantData.lastMessageSeenTime);
    });
  }

  void _fetchMessagesStream() {
    _loading = true;

    _messagesSubscription = getMessagesStream(chat.docRef).listen((QueryBatch<Message> queryBatch) {
      if (_messageMap.isEmpty) {
        _queryBatch = queryBatch;
      }

      _updateMessageMap(queryBatch.list);
      _updateMessages();

      _loading = false;
    });
  }

  Future<void> _fetchMessages() async {
    if (_loading || !_queryBatch.hasMore) return;

    _loading = true;

    _queryBatch = await getMessages(chat.docRef, _queryBatch.lastDoc);

    _updateMessageMap(_queryBatch.list);
    _updateMessages();

    _loading = false;
  }

  void _updateMessageMap(List<Message> messages) {
    for (Message message in messages) {
      _messageMap[message.docRef.id] = message;
    }
  }

  void _updateMessages() {
    List<Message> messages = _messageMap.values.toList();
    messages.sort((message1, message2) => message2.sentAt.compareTo(message1.sentAt));

    Message? lastMessage;
    List<Widget> bubbles = [];
    for (Message message in messages) {
      int daysDifference = lastMessage != null ? getDaysDifference(message.sentAt, lastMessage.sentAt) : 0;
      if (daysDifference != 0) {
        bubbles.add(DateBubble(dateTime: lastMessage!.sentAt));
      }

      MessageBubble messageBubble = MessageBubble(
        chat: chat,
        message: message,
        isMe: _isUserIndex0 == message.sentBy0,
        messageReadNotifier: messageReadNotifier,
      );

      if (lastMessage?.sentBy0 == message.sentBy0 && daysDifference == 0) {
        messageBubble.tail = false;
      }
      if (lastMessage?.sentBy0 != message.sentBy0 && daysDifference == 0) {
        messageBubble.bottomMargin = 10;
      }
      bubbles.add(messageBubble);
      lastMessage = message;
    }
    if (!_queryBatch.hasMore) {
      bubbles.add(DateBubble(dateTime: lastMessage!.sentAt));
    }

    setState(() {
      _bubbles = bubbles;
    });
  }

  @override
  void initState() {
    super.initState();

    chat = widget.args.chat;
    _isUserIndex0 = chat.participantInfo0.uid == userDetails.docRef.id;
    _participantInfo = _isUserIndex0 ? chat.participantInfo1 : chat.participantInfo0;
    activeChatId = chat.docRef.id;

    messageReadNotifier.lastMessageSeenTime = _participantInfo.lastMessageSeenTime;

    _fetchParticipantUser();
    _fetchChatStream();
    _fetchMessagesStream();
  }

  void _checkAndUpdateUserInfo(Chat chat) {
    ParticipantData userParticipantData = _isUserIndex0 ? chat.participantInfo0 : chat.participantInfo1;
    if (userParticipantData.lastMessageSeenTime.isBefore(chat.lastMessageTime)) {
      updateChatUserInfo(chat.docRef, _isUserIndex0, chat.lastMessageTime);
    }
  }

  @override
  void dispose() {
    super.dispose();

    activeChatId = null;
    _chatSubscription?.cancel();
    _messagesSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: _participantUser?.name ?? ''),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            NotificationListener<ScrollNotification>(
              onNotification: onScroll,
              child: Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: _bubbles.length,
                  itemBuilder: (context, index) => _bubbles[index],
                ),
              ),
            ),
            Container(
              // decoration: kMessageContainerDecoration,
              color: Colors.grey[300],
              padding: const EdgeInsets.only(right: 8),
              child: ChatBottomSendBar(chat: chat, isUserIndex0: _isUserIndex0),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreenArguments {
  final Chat chat;

  ChatScreenArguments(this.chat);
}
