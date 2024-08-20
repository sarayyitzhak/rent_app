import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: FirebaseOptions(
      apiKey: 'AIzaSyDW-5bhyRKZGryAWLcpXeCC5gDo0Wmameo',
      appId: '1:115036149089:android:82d681f3cff220f54aa120',
      messagingSenderId: '115036149089', //
      projectId: 'renal-app',
      storageBucket: 'renal-app.appspot.com',
    ));
  } catch (e) {
    print('error: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;
  String initRoute = WelcomeScreen.id;

  // String checkUserConnected() {
  //   try {
  //     final user = _auth.currentUser;
  //     if (user != null) {
  //       return MainScreen.id;
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  //   return WelcomeScreen.id;
  // }

  Future<String> checkUserConnected() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return MainScreen.id;
      }
    } catch (e) {
      print(e);
    }
    return WelcomeScreen.id;
  }

  Widget getScreenById(String screenId) {
    if(screenId == MainScreen.id){
      return MainScreen();
    } else {
      return WelcomeScreen();
    }
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
      home: FutureBuilder<String>(
        future: checkUserConnected(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for the future to complete, show a loading indicator
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            // Once the future is complete, navigate to the appropriate screen
            return Navigator(
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) => getScreenById(snapshot.data!),
                );
              },
            );
          } else {
            return WelcomeScreen(); // Fallback screen in case of an error
          }
        },
      ),
      routes: {
        LogoScreen.id: (context) => LogoScreen(),
        MainScreen.id: (context) => MainScreen(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        UserScreen.id: (context) => UserScreen(),
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

/*
*class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;
  String initRoute = WelcomeScreen.id;

  String checkUserConnected() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return MainScreen.id;
      }
    } catch (e) {
      print(e);
    }
    return WelcomeScreen.id;
  }

  // This widget is the root of your application.
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
      routes: {
        LogoScreen.id: (context) => LogoScreen(),
        MainScreen.id: (context) => MainScreen(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        UserScreen.id: (context) => UserScreen(),
      },
 */
