import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/screens/welcome_screen.dart';
import 'package:rent_app/globals.dart';
import '../services/cloud_services.dart';
import 'main_screen.dart';

class InitialScreen extends StatelessWidget {
  static String id = 'initial_screen';
  const InitialScreen({super.key});

  Future<String> getInitialScreen() async {
    try {
      final user = getCurrentUser();
      userUid = user?.uid;
      if (user != null) {
        userDetails = await getUserByID(userUid!);
        return MainScreen.id;
      }
    } catch (e) {
      print(e);
    }
    return WelcomeScreen.id;
  }

  Future<void> navigateToInitialScreen(BuildContext context) async {
    String initialRoute = await getInitialScreen();
    Navigator.popAndPushNamed(context, initialRoute);
  }

  @override
  Widget build(BuildContext context) {
    navigateToInitialScreen(context);
    return Scaffold(
      backgroundColor: kPastelYellow,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(kWhiteLogoImage),
              const Text(
                'BORRO',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 52,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
