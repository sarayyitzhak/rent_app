import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:rent_app/screens/add_item_screen.dart';
import 'package:rent_app/screens/category_screen.dart';
import 'package:rent_app/screens/chat_screen.dart';
import 'package:rent_app/screens/chats_screen.dart';
import 'package:rent_app/screens/item_screen.dart';
import 'package:rent_app/screens/item_grid_screen.dart';
import 'package:rent_app/screens/pending_requests_screen.dart';
import 'package:rent_app/screens/profile_screen.dart';
import 'package:rent_app/screens/rental_screen.dart';
import 'package:rent_app/screens/request_screen.dart';
import 'package:rent_app/screens/request_submitted_screen.dart';
import 'package:rent_app/screens/reviews_screen.dart';
import 'package:rent_app/screens/search_result_screen.dart';
import 'package:rent_app/screens/search_screen.dart';
import 'package:rent_app/screens/user_items_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/screens/login_screen.dart';
import 'package:rent_app/screens/initial_screen.dart';
import 'package:rent_app/screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/user_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rent_app/globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   if(message.data['type'] == 'CHAT'){
    //     int x = 8;
    //     Navigator.pushNamed(context, routeName)
      // } else if(message.data['type'] == 'REQUEST'){
      //   Navigator.pushNamed(context, UserItemsScreen.id, );
      // }
    // });
    FirebaseMessaging.onBackgroundMessage(messagingHandlerBackground);
    FirebaseAppCheck firebaseAppCheck =  await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
    ) as FirebaseAppCheck;

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveBackgroundNotificationResponse: (details) => print('--------------------------------'),);


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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // onNotificationOpenedApp(context);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kDarkYellow, // Default text color
          ),
        ),
      ),
      initialRoute: InitialScreen.id,
      onGenerateRoute: (RouteSettings settings) {
        var routes = <String, WidgetBuilder> {
          InitialScreen.id: (context) => const InitialScreen(),
          MainScreen.id: (context) => const MainScreen(),
          WelcomeScreen.id: (context) => const WelcomeScreen(),
          LoginScreen.id: (context) => const LoginScreen(),
          RegistrationScreen.id: (context) => const RegistrationScreen(),
          HomeScreen.id: (context) => const HomeScreen(),
          UserScreen.id: (context) => const UserScreen(),
          UserItemsScreen.id: (context) => const UserItemsScreen(),
          AddItemScreen.id: (context) => AddItemScreen(settings.arguments as AddItemScreenArguments),
          ItemScreen.id: (context) => ItemScreen(settings.arguments as ItemScreenArguments),
          RentalScreen.id: (context) => RentalScreen(settings.arguments as RentalScreenArguments),
          RequestSubmittedScreen.id: (context) => const RequestSubmittedScreen(),
          PendingRequestsScreen.id: (context) => const PendingRequestsScreen(),
          ChatsScreen.id: (context) => const ChatsScreen(),
          ChatScreen.id: (context) => ChatScreen(settings.arguments as ChatScreenArguments),
          SearchScreen.id: (context) => const SearchScreen(),
          SearchResultScreen.id: (context) => SearchResultScreen(settings.arguments as SearchResultScreenArguments),
          CategoryScreen.id: (context) => CategoryScreen(settings.arguments as CategoryScreenArguments),
          ProfileScreen.id: (context) => const ProfileScreen(),
          RequestScreen.id: (context) => RequestScreen(settings.arguments as RequestScreenArguments),
          ReviewsScreen.id: (context) => ReviewsScreen(settings.arguments as ReviewsScreenArguments),
          ItemGridScreen.id: (context) => ItemGridScreen(settings.arguments as ItemGridScreenArguments),
        };
        return MaterialPageRoute(builder: routes[settings.name]!);
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
    );
  }
}


