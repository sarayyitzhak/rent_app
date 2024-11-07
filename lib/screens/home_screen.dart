import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/globals.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/screens/item_grid_screen.dart';
import 'package:rent_app/screens/pending_requests_screen.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/services/query_batch.dart';
import 'package:rent_app/widgets/reusable_card.dart';
import '../constants.dart';
import 'package:rent_app/models/category.dart';
import '../services/card_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../widgets/item_widgets/item_card.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ItemCategory _selectedCategory = ItemCategory.values[0];
  final ScrollController _categoryScrollController = ScrollController();
  String? cityName;

  List<Widget> buildCategoriesList() {
    List<Widget> categoriesCards = [];

    for (ItemCategory category in ItemCategory.values) {
      categoriesCards.add(ReusableCard(
          color: _selectedCategory == category ? kActiveButtonColor : kPastelYellowOpacity,
          cardChild: Icon(
            category.icon,
            color: _selectedCategory == category ? Colors.white : kPastelYellow,
          ),
          onPress: () {
            setState(() {
              _selectedCategory = category;
              _categoryScrollController.initialScrollOffset;
            });
          }));
    }
    return categoriesCards;
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentPosition = position;
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      cityName = place.locality.toString();
    } catch (e) {
      print(e);
    }
  }

  Future<void> getLoc() async {
    await _getCurrentLocation();
    if (currentPosition != null) {
      await _getAddressFromLatLng(currentPosition!);
      setState(() {
        // Update the city name when location is retrieved
        cityName = cityName ?? 'מיקום לא ידוע'; // Fallback if cityName is still null
      });
    } else {
      setState(() {
        cityName = 'מיקום לא ידוע'; // Fallback when location is not found
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getLoc();
  }

  @override
  Widget build(BuildContext context) {
    // create10Users();
    // return Text('finished');
    var localization = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.hiWelcomeBack,
                                style: kTopHeaderTextStyle,
                              ),
                            ],
                          ),
                          IconButton(
                              onPressed: () => Navigator.pushNamed(context, PendingRequestsScreen.id),
                              icon: Icon(
                                Icons.pending_outlined,
                                color: kDarkYellow,
                              )),
                        ],
                      ),
                    ),
                    Text(
                      localization.whatWouldYouLikeToSearch,
                      style: kBlackTextStyle,
                    ),
                    SizedBox(
                      height: 85,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: buildCategoriesList(),
                      ),
                    ),

                    // Text('חיפושים אחרונים', style: kBlackHeaderTextStyle,),
                    // Container(
                    //   width: double.infinity,
                    //
                    //   color: Colors.white10,
                    //   child: Text('שמפו'),
                    // ),

                    const SizedBox(
                      height: 30,
                    ),

                    Text(
                      localization.recommendedForYou,
                      style: kBlackHeaderTextStyle,
                    ),
                    SizedBox(
                      height: 250,
                      child: FutureBuilder(
                          future: getItemsByCategory(_selectedCategory),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              QueryBatch<Item> items = snapshot.data!;
                              return ListView(
                                scrollDirection: Axis.horizontal,
                                children: items.list.map((Item item) => ItemCard(item: item, isHorizontal: true)).toList(),
                              );
                            } else {
                              return Container();
                            }
                          }),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    Row(
                      children: [
                        Text(
                          localization.aroundYou,
                          style: kBlackHeaderTextStyle,
                        ),
                        const Icon(Icons.location_on_outlined),
                        Text(cityName ?? localization.gettingLocation),
                      ],
                    ),
                    SizedBox(
                      height: 250,
                      child: currentPosition == null || cityName == null
                          ? const Center(
                              child: CircularProgressIndicator(
                              color: kPastelYellow,
                            ))
                          : FutureBuilder(
                              future:
                                  getItemsFilterByGeoPoint(currentPosition!.latitude, currentPosition!.longitude, true),
                              // future: getItemsFilterByLocation(currentPosition!, cityName!, true),TODO: decide what to do
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                                  List? itemCards = snapshot.data;
                                  return ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: itemCards as List<Widget>,
                                  );
                                } else {
                                  return Container();
                                }
                              }),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localization.lastSeen,
                          style: kBlackHeaderTextStyle,
                        ),
                        TextButton(
                            onPressed: () => Navigator.pushNamed(context, ItemGridScreen.id,
                                arguments: ItemGridScreenArguments(localization.lastSeen, getUserSeenItems)),
                            child: Text(
                              localization.show_more,
                              style: const TextStyle(color: Colors.black54),
                            ))
                      ],
                    ),
                    SizedBox(
                      height: 250,
                      child: FutureBuilder(
                          future: getUserSeenItems(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              QueryBatch<Item> items = snapshot.data!;
                              return ListView(
                                scrollDirection: Axis.horizontal,
                                children:
                                    items.list.map((Item item) => ItemCard(item: item, isHorizontal: true)).toList(),
                              );
                            } else {
                              return Container();
                            }
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
