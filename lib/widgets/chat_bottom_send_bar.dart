import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rent_app/models/chat.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/widgets/voice_recorder_button.dart';
import '../constants.dart';
import '../dialogs/select_image_dialog.dart';

class ChatBottomSendBar extends StatefulWidget {
  final Chat chat;
  final bool isUserIndex0;

  const ChatBottomSendBar({super.key, required this.chat, required this.isUserIndex0});

  @override
  State<ChatBottomSendBar> createState() => _ChatBottomSendBarState();
}

class _ChatBottomSendBarState extends State<ChatBottomSendBar> {
  final messageTextController = TextEditingController();
  String messageText = '';
  File? image;
  bool showMic = true;

  void onSendPressed() {
    if (messageTextController.text.isNotEmpty) {
      messageTextController.clear();

      sendTextMessage(widget.chat.docRef, widget.isUserIndex0, messageText);

      setState(() {
        showMic = true;
      });
    }
  }

  void onImagePressed(File newImage) {
    setState(() {
      image = newImage;
    });

    sendImageMessage(widget.chat.docRef, widget.isUserIndex0, image!);

    setState(() {
      showMic = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white60,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageTextController,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 3,
                    onChanged: (value) {
                      messageText = value;
                      setState(() {
                        showMic = false;
                        if (value.isEmpty) {
                          showMic = true;
                        }
                      });
                    },
                    decoration: kMessageTextFieldDecoration,
                  ),
                ),
                if (showMic)
                  VoiceRecorderButton(chat: widget.chat, isUserIndex0: widget.isUserIndex0),
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined),
                  onPressed: () {
                    SelectImageDialog(context).pickImage(onImagePressed);
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
          child: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: IconButton(
                onPressed: onSendPressed,
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                )),
          ),
        ),
      ],
    );
  }
}
