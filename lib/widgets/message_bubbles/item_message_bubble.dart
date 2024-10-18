
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../constants.dart';
import '../../main.dart';
import '../../models/item.dart';
import '../../models/message.dart';
import '../../screens/item_screen.dart';

class ItemMessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const ItemMessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localization = AppLocalizations.of(context)!;
    return FutureBuilder(
      future: getItemById(message.fileRef!),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Item item = snapshot.data!;
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, ItemScreen.id,
                arguments: ScreenArguments(item, item.contactUser == userDetails.userReference)),
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                Container(
                  width: 300,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue : Colors.grey[300]!,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CachedNetworkImage(
                        width: 100,
                        height: 100,
                        imageUrl: item.imageRef,
                        placeholder: (context, url) => Container(
                          padding: const EdgeInsets.all(30),
                          child: const CircularProgressIndicator(color: kPastelYellow,)
                        ),
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
                              '${item.price}₪',
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
                ),
              ],
            ),
          );
        } else {
          return Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              Container(
                width: 300,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blue : Colors.grey[300]!,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 100,
                      height: 100,
                      child: Icon(Icons.error)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        localization.errorLoadingSellerDetails,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      }
    );
  }

}