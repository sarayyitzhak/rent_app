import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_app/models/chat.dart';
import 'package:rent_app/models/message_type.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/widgets/voice_recorder_button.dart';
import 'package:rent_app/widgets/pick_image_button.dart';
import '../constants.dart';
import '../models/message.dart';


class ChatBottomSendBar extends StatefulWidget {
  Chat chat;
  int userIdx;
  ChatBottomSendBar({super.key, required this.chat, required this.userIdx});

  @override
  State<ChatBottomSendBar> createState() => _ChatBottomSendBarState();
}

class _ChatBottomSendBarState extends State<ChatBottomSendBar> {
  final storageRef = FirebaseStorage.instance.ref();
  final messageTextController = TextEditingController();
  String messageText = '';
  File? image;
  bool showMic = true;

  void onSendPressed(){
    if (messageTextController.text.isNotEmpty) {
      messageTextController.clear();
      sendMessage(widget.chat.docRef, widget.userIdx, messageText, MessageType.TEXT, null);
      setState(() {
        showMic = true;
      });
    }
  }

  void uploadImage() async {
    DateTime sentAt = Timestamp.now().toDate();
    final itemRef = storageRef.child('${widget.chat.docRef}/$sentAt');
    UploadTask uploadTask = itemRef.putFile(image!);
    TaskSnapshot taskSnapshot = await uploadTask;
    var imageUrl = await taskSnapshot.ref.getDownloadURL();
    sendMessage(widget.chat.docRef, widget.userIdx, 'תמונה', MessageType.IMAGE, imageUrl);
  }

  void onImagePressed(File? newImage){
      setState(() {
        image = newImage;
      });
      uploadImage();
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
                showMic
                    ? VoiceRecorderButton(chat: widget.chat, userIdx: widget.userIdx,)
                    : const SizedBox(),

                PickImageButton(icon: Icons.camera_alt_outlined, onImagePicked: onImagePressed),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 8.0, vertical: 0),
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



