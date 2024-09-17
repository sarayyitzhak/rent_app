import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/widgets/reusable_card.dart';
import '../add_users.dart';
import '../constants.dart';
import 'package:rent_app/models/category.dart';
import '../services/firebase_services.dart';
import '../widgets/scrollable_item_grid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'main_screen.dart';

Position? currentPosition;
String? cityName;

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ItemCategory _selectedCategory = ItemCategory.values[0];
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final storageRef = FirebaseStorage.instance.ref();
  final ScrollController _categoryScrollController = ScrollController();



  List<Widget> buildCategoriesList() {
    List<Widget> categoriesCards = [];

    for (ItemCategory category in ItemCategory.values) {
      categoriesCards.add(ReusableCard(
          color: _selectedCategory == category
              ? kActiveButtonColor
              : kPastelYellowOpacity,
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

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

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
      cityName = await place.locality.toString();
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
        cityName =
            cityName ?? 'מיקום לא ידוע'; // Fallback if cityName is still null
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Row(
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
                        ],
                      ),
                    ),
                    Text(
                      'מה תרצו לחפש?',
                      style: kBlackTextStyle,
                    ),
                    Container(
                      height: 85,
                      child: ListView(
                        children: buildCategoriesList(),
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                    
                    // Text('חיפושים אחרונים', style: kBlackHeaderTextStyle,),
                    // Container(
                    //   width: double.infinity,
                    //
                    //   color: Colors.white10,
                    //   child: Text('שמפו'),
                    // ),


                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Text(
                          'סביבך',
                          style: kBlackHeaderTextStyle,
                        ),
                        Icon(Icons.location_on_outlined),
                        Text(cityName ?? 'בודק מיקום...'),
                      ],
                    ),
                    Container(
                      height: 250,
                      child: currentPosition == null || cityName == null ? Center(child: CircularProgressIndicator(color: kPastelYellow,)) : FutureBuilder(
                          future: getHorizontalItemsFilterByLocation(
                              _firestore, currentPosition!, cityName!),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data != null &&
                                snapshot.data!.isNotEmpty) {
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
                    SizedBox(
                      height: 30,
                    ),

                    Text(
                      'מומלצים בשבילך',
                      style: kBlackHeaderTextStyle,
                    ),
                    Container(
                      height: 250,
                      child: FutureBuilder(
                          future: getHorizontalItemsFilterByCategory(
                              _firestore, _selectedCategory),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data != null &&
                                snapshot.data!.isNotEmpty) {
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

                    SizedBox(
                      height: 30,
                    ),

                    Text(
                      'נצפו לאחרונה',
                      style: kBlackHeaderTextStyle,
                    ),
                    Container(
                      height: 250,
                      child: FutureBuilder(
                          future: getHorizontalItemsFilterByLastSeen(
                              _firestore),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data != null &&
                                snapshot.data!.isNotEmpty) {
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



                    // Text(
                    //   AppLocalizations.of(context)!.categories,
                    //   style: kHeadersTextStyle,
                    // ),
                    // Container(
                    //   height: 85,
                    //   child: ListView(
                    //     children: buildCategoriesList(),
                    //     scrollDirection: Axis.horizontal,
                    //   ),
                    // ),
                    // Text(
                    //   // 'Best Sellers of ${categories[_selectedCategoryIdx].title}',
                    //   AppLocalizations.of(context)!.bestSellersOf(_selectedCategory
                    //       .title), //TODO: check how to do it with dynamic string
                    //   style: kHeadersTextStyle,
                    // ),
                  ],
                ),
              ),
              // Expanded(
              //     child: ScrollableItemGrid(
              //         future:
              //             getItemsFilterByCategory(_firestore, _selectedCategory),
              //         controller: _categoryScrollController)),
            ],
          ),
        ),
      ),
    );
  }
}
