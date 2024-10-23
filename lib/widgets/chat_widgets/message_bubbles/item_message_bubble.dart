
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../constants.dart';
import '../../../main.dart';
import '../../../models/chat.dart';
import '../../../models/item.dart';
import '../../../models/message.dart';
import '../../../screens/item_screen.dart';
import '../message_time.dart';
import '../../../utils.dart';

class ItemMessageBubble extends StatelessWidget {
  final Chat chat;
  final Message message;
  final bool isMe;
  final bool tail;

  const ItemMessageBubble({super.key, required this.chat, required this.message, required this.isMe, required this.tail});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localization = AppLocalizations.of(context)!;
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        children: [
          FutureBuilder(
              future: getItemById(message.fileRef!),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Item item = snapshot.data!;
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, ItemScreen.id,
                        arguments: ItemScreenArguments(item, item.contactUser == userDetails.userReference)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CachedNetworkImage(
                          width: 100,
                          height: 100,
                          imageUrl: item.imageRef,
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                getFormattedPrice(item.price),
                                style: kHeadersTextStyle,
                              ),
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
                } else {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                          width: 100,
                          height: 100,
                          child: Icon(Icons.error)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          localization.errorLoadingItem,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }
          ),
          const SizedBox(height: 4),
          MessageTime(chat: chat, message: message, isMe: isMe)
        ],
      ),
    );
  }

}