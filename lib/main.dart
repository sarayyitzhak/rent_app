import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rent_app/db/isar_model.dart';
import 'package:rent_app/screens/add_item_screen.dart';
import 'package:rent_app/screens/category_screen.dart';
import 'package:rent_app/screens/chat_screen.dart';
import 'package:rent_app/screens/chats_screen.dart';
import 'package:rent_app/screens/item_screen.dart';
import 'package:rent_app/screens/profile_screen.dart';
import 'package:rent_app/screens/search_result_screen.dart';
import 'package:rent_app/screens/search_screen.dart';
import 'package:rent_app/screens/user_items_screen.dart';
import 'package:rent_app/screens/wishlist_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rent_app/services/user_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/screens/login_screen.dart';
import 'package:rent_app/screens/logo_screen.dart';
import 'package:rent_app/screens/welcome_screen.dart';
import 'models/user.dart';
import 'screens/home_screen.dart';
import 'screens/user_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'db/chatDB.dart';
import 'db/messageDB.dart';
// import 'db/chat.g.dart';
// import 'message.g.dart';


String? userUid;
late UserDetails userDetails;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This function handles background notifications
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [MessageSchema, ChatSchema],
    directory: dir.path,
    inspector: true
  );
  try {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: 'AIzaSyDW-5bhyRKZGryAWLcpXeCC5gDo0Wmameo',
      appId: '1:115036149089:android:82d681f3cff220f54aa120',
      messagingSenderId: '115036149089', //
      projectId: 'renal-app',
      storageBucket: 'renal-app.appspot.com',
    ));
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('New message notification!');
    //   print('Message data: ${message.data}');
    //
    //   if (message.notification != null) {
    //     print('Notification title: ${message.notification?.title}');
    //     print('Notification body: ${message.notification?.body}');
    //     // Display notification or update chat UI
    //   }
    // });
    //
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked!');
      // Navigate to the chat screen using the chatId passed in the data payload
      // Navigator.of(context).pushNamed('/chat', arguments: message.data['chatId']);
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseAppCheck firebaseAppCheck =  await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
    ) as FirebaseAppCheck;
    // await FirebaseAppCheck.instance.activate(
    //   webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      // androidProvider: AndroidProvider.playIntegrity,
    // );
    // firebaseAppCheck.installAppCheckProviderFactory(
    //     DebugAppCheckProviderFactory.getInstance());
    // await FirebaseAppCheck.instance
    // // Your personal reCaptcha public key goes here:
    //     .activate(
    //   androidProvider: AndroidProvider.debug,
    //   appleProvider: AppleProvider.debug,
    //   webProvider: ReCaptchaV3Provider(kWebRecaptchaSiteKey),
    // );

  } catch (e) {
    print('error: $e');
  }

  runApp(ChangeNotifierProvider(
    create: (context) => IsarModel(isar),
    child: MyApp(isar: isar,),
  ),);
}

class MyApp extends StatelessWidget {
  final Isar isar;
  MyApp({super.key, required this.isar});
  final _auth = FirebaseAuth.instance;
  String initRoute = WelcomeScreen.id;
  UserServices userServices = UserServices(FirebaseAuth.instance, null); // ????

  String checkUserConnected() {
    try {
      final user = _auth.currentUser;
      userUid = userServices.getCurrentUser()?.uid;
      if (user != null) {
        return MainScreen.id;
      }
    } catch (e) {
      print(e);
    }
    return WelcomeScreen.id;
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: isar,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: kDarkYellow, // Default text color
            ),
          ),
        ),
        initialRoute: checkUserConnected(),
        // initialRoute: ItemScreen.id,
        routes: {
          LogoScreen.id: (context) => const LogoScreen(),
          MainScreen.id: (context) => const MainScreen(),
          WelcomeScreen.id: (context) => const WelcomeScreen(),
          LoginScreen.id: (context) => const LoginScreen(),
          RegistrationScreen.id: (context) => const RegistrationScreen(),
          HomeScreen.id: (context) => const HomeScreen(),
          UserScreen.id: (context) => const UserScreen(),
          UserItemsScreen.id: (context) => const UserItemsScreen(),
          AddItemScreen.id: (context) => const AddItemScreen(),
          ItemScreen.id: (context) => const ItemScreen(),
          WishlistScreen.id: (context) => const WishlistScreen(),
          ChatsScreen.id: (context) => ChatsScreen(),
          ChatScreen.id: (context) => ChatScreen(),
          SearchScreen.id: (context) => const SearchScreen(),
          SearchResultScreen.id: (context) => const SearchResultScreen(),
          CategoryScreen.id: (context) => CategoryScreen(),
          ProfileScreen.id: (context) => const ProfileScreen(),

        },
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('he'), // Hebrew
        ],
      ),
    );
  }
}


