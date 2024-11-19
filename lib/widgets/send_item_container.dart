import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/models/item.dart';
import '../models/chat.dart';
import '../screens/chat_screen.dart';
import '../services/cloud_services.dart';

class SendItemContainer extends StatefulWidget {
  final Item item;

  const SendItemContainer(this.item, {super.key});

  @override
  State<SendItemContainer> createState() => _SendItemContainerState();
}

class _SendItemContainerState extends State<SendItemContainer> {
  bool _messageSendLoading = false;
  bool _goToChat = false;
  DocumentReference? _chatRef;

  final TextEditingController _messageTextController = TextEditingController();

  Future<void> _onSendPressed() async {
    if (_messageTextController.text.isNotEmpty) {
      setState(() {
        _messageSendLoading = true;
        _goToChat = true;
      });

      _chatRef = await sendItemMessage(widget.item.contactUserID, widget.item.docRef, _messageTextController.text);

      setState(() {
        _messageSendLoading = false;
      });
    }
  }

  Future<void> _onGoToChatPressed() async {
    if (_chatRef != null) {
      setState(() {
        _messageSendLoading = true;
      });

      Chat chat = await getChat(_chatRef!);

      setState(() {
        _messageSendLoading = false;
      });

      if (mounted) {
        Navigator.pushNamed(context, ChatScreen.id, arguments: ChatScreenArguments(chat));
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _messageTextController.text = 'האם ניתן להשכיר פריט זה?';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "שלח הודעה למשכיר",
          style: kBlackHeaderTextStyle,
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black12,
                  ),
                  child: TextField(
                    controller: _messageTextController,
                    textInputAction: TextInputAction.none,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    enabled: !_goToChat,
                    maxLines: 1,
                    decoration: kMessageTextFieldDecoration,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                child: _messageSendLoading
                    ? CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: LoadingAnimationWidget.threeArchedCircle(
                          color: Colors.white,
                          size: 24,
                        ),
                      )
                    : _goToChat
                        ? GestureDetector(
                            onTap: _onGoToChatPressed,
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.blueAccent,
                                ),
                                child: Text(
                                  'פתח את הצאט',
                                  style: TextStyle(color: Colors.white),
                                )),
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: IconButton(
                              onPressed: _onSendPressed,
                              icon: const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
              )
            ],
          ),
        )
      ],
    );
  }
}
