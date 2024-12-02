import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/globals.dart';
import 'package:rent_app/screens/item_screen.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/widgets/cached_image.dart';
import 'package:rent_app/widgets/rating_stars_widget.dart';
import 'package:rent_app/widgets/favorite_button.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants.dart';
import '../../dictionary.dart';
import '../../models/item.dart';
import '../../services/current_position_service.dart';
import '../../utils.dart';

class ItemCard extends StatelessWidget {
  final Item? item;
  final bool isHorizontal;

  const ItemCard({super.key, this.item, this.isHorizontal = false});

  @override
  Widget build(BuildContext context) {
    var localization = Dictionary.getLocalization(context);
    if (item == null) {
      return Card(
        elevation: 5,
        margin: isHorizontal ? const EdgeInsets.symmetric(horizontal: 5, vertical: 10) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 50, height: 12, color: Colors.grey),
                    const SizedBox(height: 8),
                    Container(width: 100, height: 10, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    bool isMine = item!.contactUserID == userDetails.docRef.id;
    String? distanceFromMe;
    double? distance = CurrentPositionService().getDistanceFromCurrentPosition(item!.location.geoPoint);
    if (distance != null) {
      if (distance < kMaxDistance) {
        if (distance < kMaxDistanceForNearby) {
          distanceFromMe = localization.nearby;
        } else if (distance < kMaxDistanceForMeters) {
          distanceFromMe = localization.metersFromYou(distance.toStringAsFixed(0));
        } else {
          distanceFromMe = localization.kmFromYou((distance / 1000).toStringAsFixed(1));
        }
      }
    }
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ItemScreen.id, arguments: ItemScreenArguments(item: item!)),
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
                    CachedImage(
                      imageRef: getItemImageRef(item!.docRef, item!.mainImage),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    if (!isMine && distanceFromMe != null)
                      PositionedDirectional(
                        top: 8,
                        start: 8,
                        child: Card(
                          color: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                            child: Text(
                              distanceFromMe,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    if (!isMine)
                      PositionedDirectional(
                        top: 8,
                        end: 8,
                        child: GestureDetector(
                          onTap: () => toggleUserFavoriteItem(item!.docRef),
                          child: FavoriteButton(
                            item: item!,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item!.title,
                      style: kBlackHeaderTextStyle,
                    ),
                    if (item!.getRate() != null) RatingStarsWidget(rate: item!.getRate()!),
                  ],
                ),
              ), //description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item!.location.addressDataToString(),
                  style: kSmallBlackTextStyle,
                ),
              ), //place
              const Divider(
                color: kPastelYellow,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  getFormattedPrice(item!.price),
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
