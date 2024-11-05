import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/screens/item_screen.dart';
import 'package:rent_app/widgets/chat_icon_button.dart';
import 'package:rent_app/widgets/wishlist_icon_button.dart';
import '../constants.dart';
import '../models/item.dart';
import '../utils.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final bool isHorizontal;

  const ItemCard({super.key, required this.item, this.isHorizontal = false});

  @override
  Widget build(BuildContext context) {
    bool isMine = item.contactUser == userDetails.userReference;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ItemScreen.id, arguments: ItemScreenArguments(item, isMine)),
      child: Card(
        elevation: 5,
        margin: isHorizontal ? const EdgeInsets.symmetric(horizontal: 5, vertical: 10) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          width: isHorizontal ? 200 : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: item.imageRef,
                      placeholder: (context, url) => const CircularProgressIndicator(
                        color: kPastelYellow,
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    !isMine
                        ? PositionedDirectional(
                            top: 8,
                            end: 8,
                            child: WishlistIconButton(
                              item: item,
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: kBlackHeaderTextStyle,
                    ),
                    item.getRate() != null
                        ? Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: kActiveButtonColor,
                              ),
                              Text(
                                item.getRate()!.toStringAsFixed(1),
                                style: kSmallBlackTextStyle,
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ), //description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item.location.addressDataToString(),
                  style: kSmallBlackTextStyle,
                ),
              ), //place
              const Divider(
                color: kPastelYellow,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  getFormattedPrice(item.price),
                  style: kHeadersTextStyle,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
