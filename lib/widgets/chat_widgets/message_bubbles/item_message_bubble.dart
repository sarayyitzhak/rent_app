import 'package:flutter/material.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/l10n/app_localizations.dart';

import '../../../constants.dart';
import '../../../dictionary.dart';
import '../../../models/chat.dart';
import '../../../models/item.dart';
import '../../../models/message.dart';
import '../../../screens/item_screen.dart';
import '../../cached_image.dart';
import '../message_time.dart';
import '../../../utils.dart';

class ItemMessageBubble extends StatelessWidget {
  final Chat chat;
  final Message message;
  final bool isMe;
  final MessageReadNotifier messageReadNotifier;

  const ItemMessageBubble(
      {super.key, required this.chat, required this.message, required this.isMe, required this.messageReadNotifier});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localization = Dictionary.getLocalization(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        children: [
          FutureBuilder(
              future: getItemById(message.itemID ?? ''),
              builder: (context, snapshot) {
                Item? item = snapshot.data;
                bool hasError = snapshot.hasError;

                return GestureDetector(
                  onTap: () => item != null
                      ? Navigator.pushNamed(context, ItemScreen.id, arguments: ItemScreenArguments(item: item))
                      : null,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      hasError
                          ? const SizedBox(width: 100, height: 100, child: Icon(Icons.error))
                          : CachedImage(
                              width: 100,
                              height: 100,
                              imageRef: item != null ? getItemImageRef(item.docRef, item.mainImage) : null,
                              borderRadius: BorderRadius.circular(20),
                            ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasError)
                              Text(
                                localization.errorLoadingItem,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (item != null)
                              Text(
                                item.title,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (item != null)
                              Text(
                                getFormattedPrice(item.price),
                                style: kHeadersTextStyle,
                              ),
                            if (item != null)
                              Text(
                                item.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  message.text ?? '',
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              MessageTime(
                chat: chat,
                message: message,
                isMe: isMe,
                messageReadNotifier: messageReadNotifier,
              )
            ],
          )
        ],
      ),
    );
  }
}
