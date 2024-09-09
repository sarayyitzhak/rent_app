import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/models/Message.dart';
import 'package:rent_app/models/chat.dart';
import 'package:rent_app/screens/chat_screen.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart';
import '../services/firebase_services.dart';

class ChatsScreen extends StatelessWidget {
  static String id = 'chats_screen.dart';
  ChatsScreen({super.key});
  late int chatsCount;
  final _firestore = FirebaseFirestore.instance;


  @override
  Widget build(BuildContext context) {
    // final isar = Provider.of<Isar>(context);
    var localization = AppLocalizations.of(context)!;
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(title: localization.chats, isBackButton: false),
        body: StreamBuilder(
            stream:  _firestore.collection('chats').where('participants', arrayContains: userDetails.userReference).snapshots(), 
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Text('אין עדיין שיחות', style: kBlackHeaderTextStyle,)
                );
              }
              final chats = snapshot.data?.docs.reversed;
              List<ChatCard> chatCards = [];
              for (var chat in chats!) {
                chatCards.add(ChatCard(chatDoc: chat));
              }
              return ListView(
                // reverse: true,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                children: chatCards,
              );
              }

        )
        // FutureBuilder<int>(
        //   future: getChatsCount(isar),
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return Center(child: CircularProgressIndicator());
        //     } else if (snapshot.hasError) {
        //       return Center(child: Text('Error loading chats count'));
        //     } else if (snapshot.hasData) {
        //       int chatsCount = snapshot.data!;
        //       return ListView.builder(
        //         itemCount: chatsCount,
        //         itemBuilder: (context, index) {
        //           return ChatCard(index: index, isar: isar);
        //         },
        //       );
        //     } else {
        //       return Center(child: Text('No chats available'));
        //     }
        //   },
        // ),
      ),
    );
  }
}

class ChatCard extends StatefulWidget {
  // int index;
  QueryDocumentSnapshot<Map<String, dynamic>> chatDoc;
  ChatCard({super.key, required this.chatDoc});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  late Chat chatObg;

  // Future<Message?> getChat(int index) async {
  //   chat = await widget.isar.chats.get(index);
  //   lastMessage = chat?.messages.last;
  //   return lastMessage;
  // }

  Future<Chat> getChat(QueryDocumentSnapshot<Map<String, dynamic>> chat) async {
    Map<String, dynamic> chatData = chat.data();
    List<DocumentReference> participants = (chatData['participants'] as List<dynamic>)
        .map((e) => e as DocumentReference)
        .toList();
    var lastMessageSnapshot = await chat.reference.collection('messages').orderBy('sentAt', descending: true).limit(1).get();
    Map<String, dynamic> lastMessageData;
    Message lastMessage;
    if(lastMessageSnapshot.docs.isNotEmpty){
      var lastMessageDoc = lastMessageSnapshot.docs.first;
      lastMessageData = lastMessageDoc.data();
      lastMessage = Message(sender: lastMessageData['sender'], text: lastMessageData['text'], read: lastMessageData['read'], sentAt: lastMessageData['sentAt'].toDate());
      chatObg = Chat(participants: participants, cloudKey: chat.reference, lastMessage: lastMessage);
    } else {
      lastMessage = Message(sender: 0, text: 'no text yet', read: false, sentAt: Timestamp.now().toDate());
    }
    String otherUserName = await getChatUserName();
    chatObg.otherParticipantName = otherUserName;
    return chatObg;
  }

  Future<String> getChatUserName() async {
    DocumentReference otherParticipantDoc = chatObg.participants[0] == userDetails.userReference ? chatObg.participants[1] : chatObg.participants[0];
    DocumentSnapshot<Object?> otherParticipant = await otherParticipantDoc.get();
    Map<String, dynamic> otherParticipantData = otherParticipant.data() as Map<String, dynamic>;
    String name = otherParticipant['fullName'];
    return name;//can also return the full user if needed
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ChatScreen.id, arguments: ChatScreenArguments(chatObg)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // color: kBlue,
          border: Border.all(color: kActiveButtonColor)
        ),
        child: FutureBuilder(
            future: getChat(widget.chatDoc),
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: kPastelYellow,));
              } else if (snapshot.hasData) {
                Chat chatData = snapshot.data!;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(chatData.otherParticipantName as String, style: kBlackHeaderTextStyle,),
                        Text(chatData.lastMessage?.text as String, style: kSmallBlackTextStyle,),
                      ],
                    ),
                    Text('${chatData.lastMessage?.sentAt.hour}:${chatData.lastMessage?.sentAt.minute}'),
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
