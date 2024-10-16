
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/screens/pending_requests_screen.dart';
import 'package:rent_app/widgets/reusable_card.dart';
import '../constants.dart';
import 'package:rent_app/models/category.dart';
import '../main.dart';
import '../services/card_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
        cityName =
            cityName ?? 'מיקום לא ידוע'; // Fallback if cityName is still null
      });
    } else {
      setState(() {
        cityName = 'מיקום לא ידוע'; // Fallback when location is not found
      });
    }
  }

  void _showInAppAlert(BuildContext context, String? title, String? body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          // margin: EdgeInsets.all(5),
          child: AlertDialog(
            // icon: Icon(Icons.chat),
            title: Text(title ?? 'Notification'),
            content: Text(body ?? 'You have received a new message.'),
            alignment: Alignment.topCenter,
            titleTextStyle: kBlackTextStyle,
            contentTextStyle: kSmallBlackTextStyle,
            titlePadding: EdgeInsets.all(4),
            contentPadding: EdgeInsets.all(4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),

            // actions: [
            //   TextButton(
            //     child: const Text('OK'),
            //     onPressed: () {
            //       Navigator.of(context).pop(); // Close the dialog
            //     },
            //   ),
            // ],
          ),
        );
      },
    );
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
                          IconButton(onPressed: () => Navigator.pushNamed(context, PendingRequestsScreen.id), icon: Icon(Icons.pending_outlined, color: kDarkYellow,)),
                        ],
                      ),
                    ),
                    const Text(
                      'מה תרצו לחפש?',
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

                    const Text(
                      'מומלצים בשבילך',
                      style: kBlackHeaderTextStyle,
                    ),
                    SizedBox(
                      height: 250,
                      child: FutureBuilder(
                          future: getItemsFilterByCategory(_selectedCategory, true),
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

                    const SizedBox(
                      height: 30,
                    ),

                    Row(
                      children: [
                        const Text(
                          'סביבך',
                          style: kBlackHeaderTextStyle,
                        ),
                        const Icon(Icons.location_on_outlined),
                        Text(cityName ?? 'בודק מיקום...'),
                      ],
                    ),
                    SizedBox(
                      height: 250,
                      child: currentPosition == null || cityName == null ? const Center(child: CircularProgressIndicator(color: kPastelYellow,)) : FutureBuilder(
                          future: getItemsFilterByLocation(currentPosition!, cityName!, true),
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

                    const SizedBox(
                      height: 30,
                    ),

                    const Text(
                      'נצפו לאחרונה',
                      style: kBlackHeaderTextStyle,
                    ),
                    SizedBox(
                      height: 250,
                      child: FutureBuilder(
                          future: getUserItemsLastSeen(userDetails, true, true),
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
