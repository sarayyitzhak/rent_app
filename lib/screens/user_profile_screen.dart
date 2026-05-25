import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/models/user_review.dart';
import 'package:rent_app/l10n/app_localizations.dart';
import 'package:rent_app/utils.dart';
import 'package:rent_app/widgets/cached_image.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/dynamic_scrollable_item_grid.dart';
import '../dictionary.dart';
import '../constants.dart';
import 'chat_screen.dart';
import '../services/cloud_services.dart';
import '../widgets/rating_stars_widget.dart';

class UserProfileScreen extends StatefulWidget {
  static String id = 'user_profile_screen';
  final UserProfileScreenArguments args;
  const UserProfileScreen(this.args, {super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late int? _rentCount = -1;
  late int? _itemCount = 0;
  late double? _overallRate = 0;
  late double? _availabilityLevel = 0;
  late double? _punctualityLevel = 0;
  late List<UserReview> _reviews = [];
  late Map<String, UserDetails> _reviewWithWriter = {};

  Future<Map<String, UserDetails>> getUserReviewsWithWriterDetails(
      List<UserReview> reviews) async {
    Map<String, UserDetails> map = {};
    for (UserReview review in reviews) {
      map[review.docRef.id] = await getUserByID(review.userID);
    }
    return map;
  }

  Future<void> fetchData() async {
    int? itemCount = await getUserItemCount(widget.args.user.docRef);
    int? rentCount = await getUserRentCount(widget.args.user.docRef);
    double? overallRate = await getUserOverallRate(widget.args.user.docRef);
    double? availabilityLevel =
        await getUserAvailabilityLevel(widget.args.user.docRef);
    double? punctualityLevel =
        await getUserPunctualityLevel(widget.args.user.docRef);
    List<UserReview> reviews = await getUserReviews(widget.args.user.docRef);
    Map<String, UserDetails> reviewWithWriter =
        await getUserReviewsWithWriterDetails(reviews);

    if (!mounted) {
      return;
    }

    setState(() {
      _rentCount = rentCount;
      _itemCount = itemCount;
      _overallRate = overallRate;
      _availabilityLevel = availabilityLevel;
      _punctualityLevel = punctualityLevel;
      _reviews = reviews;
      _reviewWithWriter = reviewWithWriter;
    });
  }

  Future<void> _openChatWithUser() async {
    ChatOpenResult chatOpenResult =
        await getOrCreateChatWithUser(widget.args.user.docRef.id);
    if (!mounted) {
      return;
    }
    Navigator.pushNamed(context, ChatScreen.id,
        arguments: ChatScreenArguments(chatOpenResult.chat,
            isTemporaryEmptyChat: chatOpenResult.isNew));
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Widget _buildTopStats(AppLocalizations localization) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CachedImage(
            width: 70,
            height: 70,
            imageRef:
                getUserImageRef(widget.args.user.docRef, widget.args.user.photoID),
            borderRadius: BorderRadius.circular(100),
            errorIcon: Icons.person,
          ),
          Column(
            children: [
              Text(
                _rentCount.toString(),
                style: kBlackBoldTextStyle,
              ),
              Text(localization.rentals)
            ],
          ),
          Column(
            children: [
              _overallRate != 0 && _overallRate != null
                  ? RatingStarsWidget(
                      rate: _overallRate!,
                      textStyle: kBlackBoldTextStyle,
                      size: 20)
                  : const Text('-'),
              Text(localization.rating)
            ],
          ),
          Column(
            children: [
              Text(
                _itemCount.toString(),
                style: kBlackBoldTextStyle,
              ),
              Text(localization.items)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBar(String title, double value) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title), Text((value * 2).toStringAsFixed(1))],
          ),
          SizedBox(
            height: 10,
            width: double.infinity,
            child: LinearProgressIndicator(
              value: value / 5,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsStrip() {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _reviews.map((r) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Card(
              color: Colors.white70,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${_reviewWithWriter[r.docRef.id]!.name}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '"${r.text}"',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    Text(
                      dateToString(r.createdAt),
                      style: const TextStyle(color: kGreyColor),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var localization = Dictionary.getLocalization(context);
    return Scaffold(
      appBar: CustomAppBar(
          title: widget.args.user.name,
          actionIcon: Icons.chat_bubble_outline,
          onPressed: _openChatWithUser),
      body: _rentCount != -1
          ? CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopStats(localization),
                      if (_availabilityLevel != null && _availabilityLevel != 0)
                        _buildLevelBar(localization.availability, _availabilityLevel!),
                      if (_punctualityLevel != null && _punctualityLevel != 0)
                        _buildLevelBar(localization.punctuality, _punctualityLevel!),
                      if (_reviews.isNotEmpty && _reviewWithWriter.isNotEmpty)
                        _buildReviewsStrip(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localization.itemsOf(widget.args.user.name),
                              style: kBlackHeaderTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: DynamicScrollableItemGrid(
                    stream: getContactUserItemsStream(widget.args.user.docRef),
                    isScrollable: false,
                  ),
                )
              ],
            )
          : Center(
              child: LoadingAnimationWidget.stretchedDots(
                  color: Colors.grey, size: 50)),
    );
  }
}

class UserProfileScreenArguments {
  final UserDetails user;

  UserProfileScreenArguments(this.user);
}
