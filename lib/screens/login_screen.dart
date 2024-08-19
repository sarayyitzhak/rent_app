import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/screens/main_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:rent_app/widgets/rounded_button.dart';
import 'home_screen.dart';
import 'user_screen.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String email = '';
  String password = '';
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Column(
        children: [
          Text(AppLocalizations.of(context)!.welcome, style: kBlackHeaderTextStyle,),
          Text(AppLocalizations.of(context)!.pleaseEnterYourDetailsToProceed, style: kSmallBlackTextStyle,),
          Text(AppLocalizations.of(context)!.usernameOrEmail, style: kBlackTextStyle,),
          TextField(
            keyboardType: TextInputType.emailAddress,
            onChanged: (emailValue) {
            setState(() {
              email = emailValue;
            });
          },),
          Text(AppLocalizations.of(context)!.password, style: kBlackTextStyle,),
          TextField(onChanged: (passwordValue) {
            setState(() {
              password = passwordValue;
            });
          },
          obscureText: true,),
          TextButton(
            child: Text(AppLocalizations.of(context)!.login),
            style: kButtonStyle,
            onPressed: () async {
              try{
                final user = await _auth.signInWithEmailAndPassword(email: email, password: password);
                if(user != null){
                  Navigator.pushNamed(context, MainScreen.id);
                }
              } catch (e) {
                print(e);
              }
            }
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)!.forgotPassword),
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(kPastelYellow),
            ),
            onPressed: () {},
          ),
          //TODO: continue
        ],
      ),
    ),);
  }
}
