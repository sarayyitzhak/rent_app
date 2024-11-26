import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/globals.dart';
import 'package:rent_app/models/chat.dart';
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

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _selectedBottomBarIndex = 0;
  int _unreadChats = 0;
  Timer? _lastSeenTimeTimer;

  StreamSubscription? _userChatsSubscription;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const SearchScreen(),
    const UserItemsScreen(),
    const ChatsScreen(),
    // const ProfileScreen(),
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

  void _fetchUserChats() {
    _userChatsSubscription = getUserUnreadChatCountStream().listen((int unreadChats) {
      setState(() {
        _unreadChats = unreadChats;
      });
    });
  }

  void _startPeriodicUpdates() {
    updateUserLastSeenTime();

    _lastSeenTimeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      updateUserLastSeenTime();
    });
  }

  Widget _buildNotificationIcon(IconData icon, int notificationCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (notificationCount > 0)
          PositionedDirectional(
            end: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '${notificationCount < 10 ? notificationCount : '9+'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _onAppDetached() {
    updateUserLastSeenTime(false);
    if (activeChat != null) {
      bool isUserIndex0 = activeChat!.participantInfo0.uid == userDetails.docRef.id;
      updateChatUserTyping(activeChat!.docRef, isUserIndex0, false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _onAppDetached();
    } else if (state == AppLifecycleState.resumed) {
      updateUserLastSeenTime();
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _initAppData();
    _fetchUserChats();
    _startPeriodicUpdates();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _userChatsSubscription?.cancel();
    _lastSeenTimeTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (_selectedBottomBarIndex != 0) {
            setState(() {
              _selectedBottomBarIndex = 0;
            });
          } else {
            _onAppDetached();
            SystemNavigator.pop();
          }
        },
        child: IndexedStack(
          index: _selectedBottomBarIndex,
          children: _widgetOptions,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.white,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.manage_search),
            label: 'Search',
            backgroundColor: Colors.white,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'My Items',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: _buildNotificationIcon(Icons.chat_bubble, _unreadChats),
            label: 'Chats',
            backgroundColor: Colors.white,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
            backgroundColor: Colors.white,
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
