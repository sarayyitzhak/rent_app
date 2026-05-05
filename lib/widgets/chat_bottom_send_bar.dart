import 'dart:async';
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
  final VoidCallback? onMessageSent;

  const ChatBottomSendBar(
      {super.key,
      required this.chat,
      required this.isUserIndex0,
      this.onMessageSent});

  @override
  State<ChatBottomSendBar> createState() => _ChatBottomSendBarState();
}

class _ChatBottomSendBarState extends State<ChatBottomSendBar> {
  final messageTextController = TextEditingController();
  File? image;
  bool showMic = true;
  bool _isTyping = false;
  Timer? _typingTimer;

  Future<void> onSendPressed() async {
    if (messageTextController.text.isNotEmpty) {
      await sendTextMessage(
          widget.chat.docRef, widget.isUserIndex0, messageTextController.text);
      widget.onMessageSent?.call();

      _typingTimer?.cancel();
      _isTyping = false;

      messageTextController.clear();

      setState(() {
        showMic = true;
      });
    }
  }

  Future<void> onImagePressed(File newImage) async {
    setState(() {
      image = newImage;
    });

    await sendImageMessage(widget.chat.docRef, widget.isUserIndex0, image!);
    widget.onMessageSent?.call();

    setState(() {
      showMic = true;
    });
  }

  void _handleTyping() {
    if (messageTextController.text.isEmpty) {
      return;
    }

    _typingTimer?.cancel();

    if (!_isTyping) {
      _isTyping = true;
      _updateChatUserTyping();
    }

    _typingTimer = Timer(const Duration(seconds: 2), () {
      _isTyping = false;
      _updateChatUserTyping();
    });
  }

  void _updateChatUserTyping() {
    updateChatUserTyping(widget.chat.docRef, widget.isUserIndex0, _isTyping);
  }

  @override
  void initState() {
    super.initState();

    messageTextController.addListener(_handleTyping);
  }

  @override
  void dispose() {
    messageTextController.removeListener(_handleTyping);
    _typingTimer?.cancel();

    _isTyping = false;
    _updateChatUserTyping();

    super.dispose();
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
                  VoiceRecorderButton(
                    chat: widget.chat,
                    isUserIndex0: widget.isUserIndex0,
                    onMessageSent: widget.onMessageSent,
                  ),
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined),
                  onPressed: () {
                    SelectImageDialog(context).pickImage((file) {
                      onImagePressed(file);
                    });
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
