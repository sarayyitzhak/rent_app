import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/chat.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:rent_app/models/message.dart';
import 'package:rent_app/utils.dart';
import 'package:rent_app/widgets/chat_widgets/date_bubble.dart';
import '../../constants.dart';
import '../../services/cloud_services.dart';
import 'message_bubbles/message_bubble.dart';

class MessageStream extends StatefulWidget {

  final Chat chat;
  final int userIdx;
  final DocumentReference chatDoc;

  MessageStream({super.key, required this.chat, required this.userIdx, required this.chatDoc});

  @override
  State<MessageStream> createState() => _MessageStreamState();
}

class _MessageStreamState extends State<MessageStream> {

  final List<DocumentSnapshot> _messages = []; // Store fetched documents
  bool _loading = false; // To show loading indicator
  bool _hasMore = true; // Whether more documents are available
  DocumentSnapshot? _lastDocument; // Keep track of the last document

  @override
  void initState() {
    super.initState();
    _fetchMessages(20);
    _fetchNewMessages();
  }

  // Function to fetch documents
  Future<void> _fetchMessages(int limit) async {
    if (_loading || !_hasMore) return;

    _loading = true;

    QuerySnapshot querySnapshot = await getHistoricalMessages(widget.chatDoc, limit, _lastDocument);
    List<DocumentSnapshot> newDocuments = querySnapshot.docs;

    // If fewer than the limit of documents are returned, we've hit the end
    if (newDocuments.length < limit) {
      _hasMore = false;
    }

    if (newDocuments.isNotEmpty) {
      // Update the last document
      _lastDocument = newDocuments.last;

      setState(() {
        _messages.addAll(newDocuments);
      });
    }

    _loading = false;
  }

  Future<void> _fetchNewMessages() async {
    getNewMessagesStream(widget.chatDoc).listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          setState(() {
            _messages.insert(0, change.doc);
          });
        }
      }
    });
  }

  List<Widget> _getBubbles() {
    Message? lastMessage;
    List<Widget> bubbles = [];
    for (var message in _messages) {
      Map<String, dynamic> messageData = message.data() as Map<String, dynamic>;
      Message newMessage = mapAsMessage(messageData, message.reference);
      int daysDifference = lastMessage != null ? getDaysDifference(newMessage.sentAt, lastMessage.sentAt) : 0;
      if (daysDifference != 0) {
        bubbles.add(DateBubble(dateTime: lastMessage!.sentAt));
      }

      MessageBubble messageBubble = MessageBubble(
        message: newMessage,
        isMe: widget.userIdx == newMessage.sender,
      );

      if (lastMessage?.sender == newMessage.sender && daysDifference == 0) {
        messageBubble.tail = false;
      }
      if (lastMessage?.sender != newMessage.sender && daysDifference == 0) {
        messageBubble.bottomMargin = 10;
      }
      bubbles.add(messageBubble);
      lastMessage = newMessage;
    }
    if (!_hasMore) {
      bubbles.add(DateBubble(dateTime: lastMessage!.sentAt));
    }
    return bubbles;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !_loading) {
          _fetchMessages(20);
        }
        return false;
      },
      child: Expanded(
        child: ListView(
          reverse: true,
          children: _getBubbles(),
        ),
      ),
    );
  }
}