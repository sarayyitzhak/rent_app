import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/screens/chats_screen.dart';
import 'package:rent_app/screens/search_screen.dart';
import 'package:rent_app/screens/user_items_screen.dart';
import '../services/cloud_services.dart';
import 'home_screen.dart';
import 'user_screen.dart';

class MainScreen extends StatefulWidget {
  static String id = 'main_screen';

  const MainScreen({super.key});
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedBottomBarIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const SearchScreen(),
    const UserItemsScreen(),
    const ChatsScreen(),
    const UserScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedBottomBarIndex = index;
    });
  }

  Future<void> requestMicrophonePermission() async {
    await Permission.microphone.request();
  }

  Future<void> _initAppData() async {
    await getUser();
    requestMicrophonePermission();
    requestNotificationsPermission();
    onTokenRefreshed();
    // messagingListenForeground();
    setToken();
    onMessageOpenedApp(context);

    deleteOldUserItemSeen(DateTime.now().subtract(const Duration(days: 60)));
  }

  @override
  void initState() {
    super.initState();

    _initAppData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: _selectedBottomBarIndex == 0,
        onPopInvokedWithResult: (didPop, result) {
          setState(() {
            _selectedBottomBarIndex = 0;
          });
        },
        child: _widgetOptions[_selectedBottomBarIndex],
      ),
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
