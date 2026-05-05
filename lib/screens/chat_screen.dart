import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rent_app/models/chat.dart';
import 'package:rent_app/globals.dart';
import 'package:rent_app/widgets/chat_bottom_send_bar.dart';
import 'package:rent_app/widgets/chat_widgets/chat_app_bar.dart';
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

  final List<Widget> _bubbles = [];
  QueryBatch<Message> _queryBatch = QueryBatch.empty();
  Message? _firstMessage;
  Message? _lastMessage;
  bool _loading = false;
  bool _messageSentInSession = false;

  final MessageReadNotifier messageReadNotifier = MessageReadNotifier();
  final MessageTailsNotifier messageTailsNotifier = MessageTailsNotifier();

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

  void _fetchChatStream() {
    _chatSubscription = getChatStream(chat.docRef).listen((Chat chat) {
      _checkAndUpdateUserInfo(chat);

      ParticipantData participantData =
          _isUserIndex0 ? chat.participantInfo1 : chat.participantInfo0;
      messageReadNotifier
          .updateLastMessageSeenTime(participantData.lastMessageSeenTime);
    });
  }

  void _fetchMessagesStream() {
    _loading = true;

    _messagesSubscription =
        getMessagesStream(chat.docRef).listen((QueryBatch<Message> queryBatch) {
      if (queryBatch.size == 0) {
        return;
      }

      if (_bubbles.isEmpty) {
        _queryBatch = queryBatch;
      }

      setState(() {
        _bubbles.insertAll(
            0, _getMessageBubbles(queryBatch.list, _bubbles.isNotEmpty));
      });

      _lastMessage = queryBatch.list.first;

      _loading = false;
    });
  }

  Future<void> _fetchMessages() async {
    if (_loading || !_queryBatch.hasMore) return;

    _loading = true;

    _queryBatch = await getMessages(chat.docRef, _queryBatch.lastDoc);

    setState(() {
      _bubbles.addAll(_getMessageBubbles(_queryBatch.list, false));
    });

    _loading = false;
  }

  List<Widget> _getMessageBubbles(List<Message> messages, bool isNewMessages) {
    return isNewMessages
        ? _getNewMessageBubbles(messages)
        : _getOldMessageBubbles(messages);
  }

  List<Widget> _getNewMessageBubbles(List<Message> messages) {
    List<Widget> bubbles = [];
    for (Message message in messages) {
      int daysDifference = _lastMessage != null
          ? getDaysDifference(message.sentAt, _lastMessage!.sentAt)
          : 0;

      messageTailsNotifier.add(message.docRef.id);
      if (_lastMessage?.sentBy0 == message.sentBy0 && daysDifference == 0) {
        messageTailsNotifier.remove(_lastMessage!.docRef.id);
      }

      MessageBubble messageBubble = MessageBubble(
        key: ValueKey(message.docRef.id),
        chat: chat,
        message: message,
        isMe: _isUserIndex0 == message.sentBy0,
        topMargin:
            _lastMessage?.sentBy0 != message.sentBy0 && daysDifference == 0
                ? 9
                : 1,
        bottomMargin: 1,
        messageReadNotifier: messageReadNotifier,
        messageTailsNotifier: messageTailsNotifier,
      );

      bubbles.add(messageBubble);
      if (daysDifference != 0) {
        DateTime sentAt = message.sentAt;
        bubbles.add(DateBubble(
            key: ValueKey(sentAt.millisecondsSinceEpoch.toString()),
            dateTime: sentAt));
      }
    }
    return bubbles;
  }

  List<Widget> _getOldMessageBubbles(List<Message> messages) {
    List<Widget> bubbles = [];
    for (Message message in messages) {
      int daysDifference = _firstMessage != null
          ? getDaysDifference(message.sentAt, _firstMessage!.sentAt)
          : 0;
      if (daysDifference != 0) {
        DateTime sentAt = _firstMessage!.sentAt;
        bubbles.add(DateBubble(
            key: ValueKey(sentAt.millisecondsSinceEpoch.toString()),
            dateTime: sentAt));
      }

      if (_firstMessage?.sentBy0 != message.sentBy0 || daysDifference > 0) {
        messageTailsNotifier.add(message.docRef.id);
      }

      MessageBubble messageBubble = MessageBubble(
        key: ValueKey(message.docRef.id),
        chat: chat,
        message: message,
        isMe: _isUserIndex0 == message.sentBy0,
        bottomMargin: _firstMessage != null &&
                _firstMessage?.sentBy0 != message.sentBy0 &&
                daysDifference == 0
            ? 9
            : 1,
        topMargin: 1,
        messageReadNotifier: messageReadNotifier,
        messageTailsNotifier: messageTailsNotifier,
      );

      bubbles.add(messageBubble);
      _firstMessage = message;
    }
    if (!_queryBatch.hasMore) {
      DateTime sentAt = _firstMessage!.sentAt;
      bubbles.add(DateBubble(
          key: ValueKey(sentAt.millisecondsSinceEpoch.toString()),
          dateTime: sentAt));
    }
    return bubbles;
  }

  @override
  void initState() {
    super.initState();

    chat = widget.args.chat;
    _isUserIndex0 = chat.participantInfo0.uid == userDetails.docRef.id;
    _participantInfo =
        _isUserIndex0 ? chat.participantInfo1 : chat.participantInfo0;
    activeChat = chat;

    messageReadNotifier.lastMessageSeenTime =
        _participantInfo.lastMessageSeenTime;

    _fetchChatStream();
    _fetchMessagesStream();
  }

  void _checkAndUpdateUserInfo(Chat chat) {
    ParticipantData userParticipantData =
        _isUserIndex0 ? chat.participantInfo0 : chat.participantInfo1;
    if (userParticipantData.lastMessageSeenTime
        .isBefore(chat.lastMessageTime)) {
      updateChatUserInfo(chat.docRef, _isUserIndex0, chat.lastMessageTime);
    }
  }

  @override
  void dispose() {
    if (widget.args.isTemporaryEmptyChat && !_messageSentInSession) {
      deleteChatIfEmpty(chat.docRef);
    }
    activeChat = null;
    _chatSubscription?.cancel();
    _messagesSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(chat: chat),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            NotificationListener<ScrollNotification>(
              onNotification: onScroll,
              child: Expanded(
                child: ListView.custom(
                  reverse: true,
                  childrenDelegate: SliverChildBuilderDelegate(
                    (context, i) {
                      return _bubbles[i];
                    },
                    childCount: _bubbles.length,
                    findChildIndexCallback: (key) {
                      return _bubbles.indexWhere((m) => m.key == key);
                    },
                  ),
                ),
              ),
            ),
            Container(
              // decoration: kMessageContainerDecoration,
              color: Colors.grey[300],
              padding: const EdgeInsets.only(right: 8),
              child: ChatBottomSendBar(
                chat: chat,
                isUserIndex0: _isUserIndex0,
                onMessageSent: () {
                  _messageSentInSession = true;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreenArguments {
  final Chat chat;
  final bool isTemporaryEmptyChat;

  ChatScreenArguments(this.chat, {this.isTemporaryEmptyChat = false});
}
