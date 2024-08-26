import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/screens/login_screen.dart';
import 'package:rent_app/screens/registration_screen.dart';
import 'package:rent_app/widgets/custom_button.dart';


class WelcomeScreen extends StatelessWidget {
  static String id = 'welcome_screen';
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(kYellowLogoImage),
              Text(
                'BORRO',
                style: TextStyle(
                    color: kPastelYellow,
                    fontSize: 60,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold),
              ),
              CustomButton(title: AppLocalizations.of(context)!.login, onPress: () {Navigator.pushNamed(context, LoginScreen.id);}, buttonStyle: kDarkButtonStyle,),
              CustomButton(title: AppLocalizations.of(context)!.signUp, onPress: () {Navigator.pushNamed(context, RegistrationScreen.id);}, buttonStyle: kLightButtonStyle,),

            ],
          ),
        ),
      ),
    );
  }
}

