import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/db/chatDB.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/screens/chats_screen.dart';
import 'package:rent_app/screens/search_screen.dart';
import 'package:rent_app/screens/user_items_screen.dart';
import '../db/messageDB.dart';
import 'home_screen.dart';
import 'user_screen.dart';
import 'login_screen.dart';

// Position? currentPosition;
// String? cityName;

class MainScreen extends StatefulWidget {
  static String id = 'main_screen';

  const MainScreen({super.key});
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedBottomBarIndex = 0;


  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SearchScreen(),
    UserItemsScreen(),
    ChatsScreen(),
    // LoginScreen(),
    UserScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedBottomBarIndex = index;
    });
  }

  Future<UserDetails> getUser() async {
    userDetails = await getUserDetailsByUid(userUid!);
    return userDetails;
  }

  // Future<void> _getCurrentLocation() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return Future.error('Location services are disabled.');
  //   }
  //
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error('Location permissions are permanently denied.');
  //   }
  //
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //
  //   setState(() {
  //     currentPosition = position;
  //   });
  // }
  //
  // Future<void> _getAddressFromLatLng(Position position) async {
  //   try {
  //     List<Placemark> placemarks = await placemarkFromCoordinates(
  //       position.latitude,
  //       position.longitude,
  //     );
  //
  //     Placemark place = placemarks[0];
  //     cityName = await place.locality.toString();
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  //
  // Future<void> getLoc() async {
  //   await _getCurrentLocation();
  //   if (currentPosition != null) {
  //     await _getAddressFromLatLng(currentPosition!);
  //     setState(() {
  //       cityName =
  //           cityName ?? 'מיקום לא ידוע';
  //     });
  //   } else {
  //     setState(() {
  //       cityName = 'מיקום לא ידוע';
  //     });
  //   }
  // }

  Future<void> syncData(Isar isar) async {
    await getUser();
    for (DocumentReference chat in userDetails.chats) {
      var chatDoc = await chat.get();
      var chatData = chatDoc.data() as Map<String, dynamic>;
      List participants = chatData['participants'];
      List participantsAsString = participants.map((p) => p.path).toList();
      DocumentReference otherParticipant = participants.firstWhere((p) => p != userDetails.userReference);
      String otherParticipantAsString = otherParticipant.path;
      DocumentSnapshot<Object?> otherParticipantDoc = await otherParticipant.get();
      var otherParticipantData = otherParticipantDoc.data() as Map<String, dynamic>;
      String otherParticipantName = otherParticipantData['fullName'];
      var messagesSnapshot = await chat.collection('messages').get();

      var chatInDB = await isar.chats.filter().participantsElementEqualTo(otherParticipantAsString).findFirst();
      if (chatInDB != null) {
        //chat exist in both, just sync it
        int messagesCount = chatInDB.messages.length;
        if (messagesSnapshot.size != messagesCount){
          //changed, get messages that added
          var lastMessageInDB = chatInDB.messages.last;
          Timestamp lastMessageTimeInDB = Timestamp.fromDate(lastMessageInDB.sentAt);
          for(var message in messagesSnapshot.docs){
            Map<String, dynamic> messageData = message.data();
            Timestamp messageTime = messageData['sentAt'];
            if(messageTime.compareTo(lastMessageTimeInDB) > 0){
              Message newMessage = Message()
                ..sender = messageData['sender']
                ..text = messageData['text']
                ..read = messageData['read']
                ..sentAt = messageData['sentAt'].toDate()
                ..senderName = otherParticipantName;

              await isar.writeTxn(() async {
                await isar.messages.put(newMessage);
                chatInDB.messages.add(newMessage);
                await chatInDB.messages.save();
              });
            }

          }
        }
      } else {
        //need to fetch it from firebase
        final chat = Chat()..participants = participantsAsString.cast<String>()..cloudKey = chatDoc.id;
        List messagesList = [];
        for (var doc in messagesSnapshot.docs) {
          var messageData = doc.data();
          final message = Message()
            ..sender = messageData['sender']
            ..read = messageData['read']
            ..text = messageData['text']
            ..sentAt = messageData['sentAt'].toDate()
            ..senderName = otherParticipantName;
            // ..senderRef = otherParticipant
            // ..messRef = doc.reference;
          messagesList.add(message);
        }
        await isar.writeTxn(() async {
          await isar.chats.put(chat);
          for (var messageToPut in messagesList) {
            await isar.messages.put(messageToPut);
            chat.messages.add(messageToPut);
          }
          await chat.messages.save();
        });
      }
    }
  }

  @override
  void initState() {
    getUser();
    // getLoc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isar = Provider.of<Isar>(context);
    // syncData(isar);
    return Scaffold(
      body: _widgetOptions[_selectedBottomBarIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'My Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
        showSelectedLabels: true,
        selectedItemColor: kActiveButtonColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedBottomBarIndex,
        iconSize: 30,
        onTap: _onItemTapped,
      ),
    );
  }
}
