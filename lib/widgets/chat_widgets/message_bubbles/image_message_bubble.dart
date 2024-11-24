import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/widgets/cached_image.dart';
import 'package:rent_app/widgets/chat_widgets/message_time.dart';
import '../../../models/chat.dart';
import '../../../models/message.dart';
import '../../../screens/image_view_gallery_screen.dart';

class ImageMessageBubble extends StatelessWidget {
  final Chat chat;
  final Message message;
  final bool isMe;
  final MessageReadNotifier messageReadNotifier;

  const ImageMessageBubble(
      {super.key,
      required this.chat,
      required this.message,
      required this.isMe,
      required this.messageReadNotifier});

  @override
  Widget build(BuildContext context) {
    Reference fileRef = getMessageFileRef(message.docRef);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, ImageViewGalleryScreen.id,
                arguments: ImageViewGalleryScreenArguments([fileRef]));
          },
          child: CachedImage(
            imageRef: fileRef,
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.width * 0.9,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 4),
        MessageTime(
          chat: chat,
          message: message,
          isMe: isMe,
          messageReadNotifier: messageReadNotifier,
        )
      ],
    );
  }
}
