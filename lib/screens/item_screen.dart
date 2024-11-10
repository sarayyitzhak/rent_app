import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/globals.dart';
import 'package:rent_app/models/condition.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/screens/add_item_screen.dart';
import 'package:rent_app/screens/rental_screen.dart';
import 'package:rent_app/screens/reviews_screen.dart';
import 'package:rent_app/utils.dart';
import 'package:rent_app/widgets/chat_icon_button.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/custom_button.dart';
import 'package:rent_app/widgets/rating_stars_widget.dart';
import 'package:rent_app/widgets/favorite_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../services/cloud_services.dart';
import '../widgets/cached_image.dart';
import '../widgets/dial_icon_button.dart';

class ItemScreen extends StatefulWidget {
  static String id = 'item_screen.dart';

  final ItemScreenArguments args;

  const ItemScreen(this.args, {super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  Item? _item;
  UserDetails? _userDetails;
  List<Reference> _imageRefs = [];
  int _reviewCount = 0;

  bool isMe = false;

  final PageController _pageController = PageController();

  Future<void> _fetchData() async {
    Item item = widget.args.item ?? await getItemByRef(widget.args.itemRef!);
    isMe = item.contactUserID == userDetails.docRef.id;
    UserDetails details = isMe ? userDetails : await getUserByID(item.contactUserID);
    List<Reference> imageRefs = await getFileReferences(getItemImageDirRef(item.docRef));
    int reviewCount = await getTextItemReviewsCount(item.docRef);

    Reference? mainImage = imageRefs.where((ref) => ref.name.startsWith(item.mainImage)).firstOrNull;

    setState(() {
      _item = item;
      _userDetails = details;

      _imageRefs = mainImage != null ? [mainImage] : [];
      for (Reference imageRef in imageRefs) {
        if (imageRef == mainImage) {
          continue;
        }
        _imageRefs.add(imageRef);
      }

      _reviewCount = reviewCount;
    });

    if (!isMe) {
      updateUserItemSeen(_item!.docRef);
    }
  }

  @override
  void initState() {
    super.initState();

    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    double? rate = _item?.getRate();

    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        isBackButton: true,
      ),
      body: _item != null
          ? SingleChildScrollView(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 300,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _imageRefs.length,
                        itemBuilder: (context, index) {
                          return CachedImage(
                            imageRef: _imageRefs[index],
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: _imageRefs.length,
                            effect: const ScrollingDotsEffect(
                              dotHeight: 10,
                              dotWidth: 10,
                              activeDotColor: Colors.blue,
                              dotColor: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isMe
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                      // padding: EdgeInsets.all(10),
                                      margin: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: kPastelYellowOpacity, borderRadius: BorderRadius.circular(10)),
                                      child: ListTile(
                                        title: Text(
                                          '${_item!.favoriteCount} ${localization.peopleLikedTheItem} ',
                                          style: kSmallBlackTextStyle,
                                        ),
                                        leading: const Icon(Icons.favorite),
                                        iconColor: Colors.pinkAccent,
                                      )),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: kPastelYellowOpacity, borderRadius: BorderRadius.circular(10)),
                                    child: ListTile(
                                      title: Text('${_item!.seenCount} ${localization.peopleSeenTheItem} ',
                                          style: kSmallBlackTextStyle),
                                      leading: const Icon(Icons.remove_red_eye),
                                      iconColor: Colors.blue.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _item!.title,
                          style: kBlackHeaderTextStyle,
                        ),
                      ),
                      Text(
                        _item!.description,
                        style: kSmallBlackTextStyle,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: kPastelYellowOpacity,
                        ),
                        child: Text(_item!.condition.getTitle(localization)),
                      ),
                      const Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localization.contactUserDetails,
                                style: kBlackHeaderTextStyle,
                              ),
                              Text(
                                _userDetails!.name,
                                style: kBlackTextStyle,
                              ),
                              Text(
                                _item!.location.addressDataToString(),
                                style: kBlackTextStyle,
                              ),
                            ],
                          ),
                          DialIconButton(phoneNumber: phoneNumberToString(_userDetails!.phoneNumber)),
                        ],
                      ),
                      const Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getFormattedPrice(_item!.price),
                            style: kHeadersTextStyle,
                          ),
                          isMe
                              ? Container()
                              : Row(
                                  children: [
                                    FavoriteButton(item: _item!),
                                    const SizedBox(width: 5),
                                    ChatIconButton(item: _item!),
                                  ],
                                )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _reviewCount != 0
                              ? TextButton(
                                  child: Text('${localization.usersReviews} ($_reviewCount)'),
                                  onPressed: () => Navigator.pushNamed(context, ReviewsScreen.id,
                                      arguments: ReviewsScreenArguments(_item!)),
                                )
                              : Text(
                                  localization.noReviewsYet,
                                  style: kBlackTextStyle,
                                ),
                          if (rate != null) RatingStarsWidget(rate: rate)
                        ],
                      ),
                    ],
                  ),
                ),
                Center(
                    child: CustomButton(
                  title: isMe ? localization.edit : localization.rentItem,
                  onPress: isMe
                      ? () => Navigator.pushNamed(context, AddItemScreen.id,
                          arguments: AddItemScreenArguments(item: _item!, isEditMode: true))
                      : () =>
                          Navigator.pushNamed(context, RentalScreen.id, arguments: RentalScreenArguments(item: _item!)),
                )),
              ],
            ))
          : Center(child: LoadingAnimationWidget.stretchedDots(color: Colors.grey, size: 50)),
    );
  }
}

class ItemScreenArguments {
  final DocumentReference? itemRef;
  final Item? item;

  ItemScreenArguments({this.itemRef, this.item});
}
