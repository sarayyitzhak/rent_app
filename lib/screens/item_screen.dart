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
import 'package:rent_app/screens/image_view_gallery_screen.dart';
import 'package:rent_app/screens/rental_screen.dart';
import 'package:rent_app/screens/reviews_screen.dart';
import 'package:rent_app/screens/user_profile_screen.dart';
import 'package:rent_app/utils.dart';
import 'package:rent_app/widgets/custom_button.dart';
import 'package:rent_app/widgets/rating_stars_widget.dart';
import 'package:rent_app/widgets/favorite_button.dart';
import 'package:rent_app/widgets/send_item_container.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../dictionary.dart';
import '../services/address_service.dart';
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
    int reviewCount = await getTextItemReviewsCount(item.docRef);

    setState(() {
      _item = item;
      _userDetails = details;
      _imageRefs = getItemImageReferencesSorted(item);
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
    var localization = Dictionary.getLocalization(context);
    double? rate = _item?.getRate();

    return Scaffold(
      body: SafeArea(
        child: _item != null
            ? SingleChildScrollView(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, ImageViewGalleryScreen.id,
                        arguments: ImageViewGalleryScreenArguments(_imageRefs, _pageController.page?.toInt() ?? 0)),
                    child: Stack(
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
                        PositionedDirectional(
                          top: 8,
                          start: 8,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Card(
                              color: Colors.black.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (!isMe)
                          PositionedDirectional(
                            top: 8,
                            end: 8,
                            child: GestureDetector(
                              onTap: () => toggleUserFavoriteItem(_item!.docRef),
                              child: Card(
                                color: Colors.black.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: FavoriteButton(item: _item!),
                                ),
                              ),
                            ),
                          ),
                        if (_imageRefs.length > 1)
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Card(
                                color: Colors.black.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: SmoothPageIndicator(
                                    controller: _pageController,
                                    count: _imageRefs.length,
                                    onDotClicked: _pageController.jumpToPage,
                                    effect: const ScrollingDotsEffect(
                                      dotHeight: 6,
                                      dotWidth: 6,
                                      activeDotColor: Colors.white,
                                      dotColor: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isMe)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
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
                          ),
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
                        SendItemContainer(_item!),
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
                                if(_userDetails != null) GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, UserProfileScreen.id, arguments: UserProfileScreenArguments(_userDetails!)),
                                  child: Row(
                                    children: [
                                      CachedImage(
                                        width: 50,
                                        height: 50,
                                        imageRef: getUserImageRef(_userDetails!.docRef, _userDetails!.photoID),
                                        borderRadius: BorderRadius.circular(100),
                                        errorIcon: Icons.person,
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _userDetails!.name,
                                              style: kBlackTextStyle,
                                            ),
                                            FutureBuilder(
                                            future: AddressService().getAddress(_item!.geoPoint),
                                            builder: (context, snapshot) =>Text(
                                              snapshot.data ?? '',
                                              style: kBlackTextStyle,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),],
                                  ),
                                ),
                              ],
                            ),
                            if (_userDetails!.showPhoneNumber)
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
                        : () => Navigator.pushNamed(context, RentalScreen.id,
                            arguments: RentalScreenArguments(item: _item!)),
                  )),
                ],
              ))
            : Center(child: LoadingAnimationWidget.stretchedDots(color: Colors.grey, size: 50)),
      ),
    );
  }
}

class ItemScreenArguments {
  final DocumentReference? itemRef;
  final Item? item;

  ItemScreenArguments({this.itemRef, this.item});
}
