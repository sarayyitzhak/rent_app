import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rent_app/db/isar_model.dart';
import 'package:rent_app/screens/add_item_screen.dart';
import 'package:rent_app/screens/chat_screen.dart';
import 'package:rent_app/screens/chats_screen.dart';
import 'package:rent_app/screens/item_screen.dart';
import 'package:rent_app/screens/user_items_screen.dart';
import 'package:rent_app/screens/wishlist_screen.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
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
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'db/chatDB.dart';
import 'db/messageDB.dart';
// import 'db/chat.g.dart';
// import 'message.g.dart';


String? userUid;
late UserDetails userDetails;

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
          LogoScreen.id: (context) => LogoScreen(),
          MainScreen.id: (context) => MainScreen(),
          WelcomeScreen.id: (context) => WelcomeScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          RegistrationScreen.id: (context) => RegistrationScreen(),
          HomeScreen.id: (context) => HomeScreen(),
          UserScreen.id: (context) => UserScreen(),
          UserItemsScreen.id: (context) => UserItemsScreen(),
          AddItemScreen.id: (context) => AddItemScreen(),
          ItemScreen.id: (context) => ItemScreen(),
          WishlistScreen.id: (context) => WishlistScreen(),
          ChatsScreen.id: (context) => ChatsScreen(),
          ChatScreen.id: (context) => ChatScreen(),
        },
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'), // English
          Locale('he'), // Hebrew
        ],
      ),
    );
  }
}


