import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/globals.dart';
import 'package:rent_app/models/item_request.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/utils.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/rating_stars_widget.dart';
import '../widgets/scrollable_active_rent_list.dart';

class ProfileScreen extends StatefulWidget {
  static String id = 'profile_screen';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _image;
  late List<ItemRequest> _currentMonthRentsFromMe = [];
  late List<ItemRequest> _currentMonthRentsOfMe = [];
  late List<ItemRequest> _activeRentalOfMe = [];
  late List<ItemRequest> _activeRentalFromMe = [];
  late double? _overallRate = -1;
  late double? _availabilityLevel = 0;
  late double? _punctualityLevel = 0;

  int getMonthlyOutcome(List<ItemRequest> requests) {
    return requests.fold(0, (sum, req) => sum + req.price);
  }

  Future<void> fetchData() async {
    String? image = getCurrentUser()?.photoURL;
    List<ItemRequest> currentMonthRentsFromMe = await getUserApprovedRequestsFrom(DateTime(DateTime.now().year, DateTime.now().month), true);
    List<ItemRequest> currentMonthRentsOfMe = await getUserApprovedRequestsFrom(DateTime(DateTime.now().year, DateTime.now().month), false);
    double? overallRate = await getUserOverallRate();
    double? availabilityLevel = await getUserAvailabilityLevel();
    double? punctualityLevel = await getUserPunctualityLevel();
    List<ItemRequest> activeRentalOfMe = await getCurrentRents(false);
    List<ItemRequest> activeRentalFromMe = await getCurrentRents(true);
    setState(() {
      _currentMonthRentsFromMe = currentMonthRentsFromMe;
      _currentMonthRentsOfMe = currentMonthRentsOfMe;
      _image = image;
      _overallRate = overallRate;
      _availabilityLevel = availabilityLevel;
      _punctualityLevel = punctualityLevel;
      _activeRentalOfMe = activeRentalOfMe;
      _activeRentalFromMe = activeRentalFromMe;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: CustomAppBar(title: localization.profile),
        body: _overallRate != -1 ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'שלום, ${userDetails.name}!',
                    style: kTopHeaderTextStyle,
                  ),
                  CircleAvatar(
                      radius: 30,
                      child: _image != null ? null : Icon(Icons.person, size: 40),
                      backgroundImage: _image != null ? CachedNetworkImageProvider(_image!) : null)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('הרווחת החודש'),
                      Text(
                        getFormattedPrice(getMonthlyOutcome(_currentMonthRentsFromMe)),
                        style: kBlackBigTextStyle,
                      ),
                    ],
                  ),
                  SizedBox(width: 50),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('שכרו ממך החודש'),
                      Text(
                        _currentMonthRentsFromMe.length.toString(),
                        style: kBlackBigTextStyle,
                      ),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text('דירוגך הכללי הוא'),
                      _overallRate != null
                          ? RatingStarsWidget(
                          rate: userDetails.getRate()!,
                          textStyle: kBlackBigTextStyle,
                          size: 40)
                          : Text('-', style: kBlackBigTextStyle),
                    ],
                  ),
                  SizedBox(width: 80),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('השכרת החודש'),
                      Text(
                        _currentMonthRentsOfMe.length.toString(),
                        style: kBlackBigTextStyle,
                      ),
                    ],
                  )
                ],
              ),
            ),
            if(_availabilityLevel != null && _availabilityLevel != 0) Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('זמינות'), Text((_availabilityLevel! * 2).toStringAsFixed(1))],
                  ),
                  SizedBox(
                    height: 10,
                    width: double.infinity,
                    child: LinearProgressIndicator(
                      value: _availabilityLevel! / 5,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
            if(_punctualityLevel != null && _punctualityLevel != 0) Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('עמידה בזמנים'), Text((_punctualityLevel! * 2).toStringAsFixed(1))],
                  ),
                  SizedBox(
                    height: 10,
                    width: double.infinity,
                    child: LinearProgressIndicator(
                      value: _punctualityLevel! / 5,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
            if(_activeRentalOfMe != []) ScrollableActiveRentList(
              isRentedFromMe: false,
              title: 'אני משכיר',
              rentals: _activeRentalOfMe,
            ),
            if(_activeRentalFromMe != []) ScrollableActiveRentList(
              isRentedFromMe: true,
              title: 'משכירים ממני',
              rentals: _activeRentalFromMe,
            ),
          ],
        ) : Center(child: LoadingAnimationWidget.stretchedDots(color: Colors.grey, size: 50)),);
  }
}
