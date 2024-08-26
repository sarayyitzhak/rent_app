import 'package:rent_app/screens/add_item_screen.dart';
import 'package:rent_app/screens/user_items_screen.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rent_app/services/user_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/screens/login_screen.dart';
import 'package:rent_app/screens/logo_screen.dart';
import 'package:rent_app/screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/user_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';

String? userUid;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _auth = FirebaseAuth.instance;
  // late final loggedInUser;
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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kDarkYellow, // Default text color
          ),
        ),
      ),
      initialRoute: checkUserConnected(),
      // initialRoute: WelcomeScreen.id,
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
    );
  }
}
