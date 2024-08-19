import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'home_screen.dart';
import 'main_screen.dart';
import 'user_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;

  String name = '';
  String email = '';
  String phoneNumber = '';
  String dateOfBirthday = '';
  String password = '';
  String confirmPassword = '';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.createAccount),
          titleTextStyle: kTopHeaderTextStyle,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              //Back
              //
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.fullName,
                  style: kBlackTextStyle,
                ),
                TextField(
                  decoration: kTextFieldDecoration,
                  onChanged: (nameValue) {
                    setState(() {
                      name = nameValue;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  AppLocalizations.of(context)!.email,
                  style: kBlackTextStyle,
                ),
                TextField(
                  decoration: kTextFieldDecoration,
                  onChanged: (emailValue) {
                    setState(() {
                      email = emailValue;
                    });
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: 20,
                ),

                Text(
                  AppLocalizations.of(context)!.mobileNumber,
                  style: kBlackTextStyle,
                ),
                TextField(
                  decoration: kTextFieldDecoration,
                  onChanged: (phoneNumberValue) {
                    setState(() {
                      phoneNumber = phoneNumberValue;
                    });
                  },
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(
                  height: 20,
                ),

                Text(
                  AppLocalizations.of(context)!.dateOfBirth,
                  style: kBlackTextStyle,
                ),
                TextField(
                  decoration: kTextFieldDecoration,
                  onChanged: (dateValue) {
                    setState(() {
                      dateOfBirthday = dateValue;
                    });
                  },
                  keyboardType: TextInputType.datetime,
                ),
                SizedBox(
                  height: 20,
                ),//Todo: change to date

                Text(
                  AppLocalizations.of(context)!.password,
                  style: kBlackTextStyle,
                ),
                TextField(
                  decoration: kTextFieldDecoration,
                  onChanged: (passwordValue) {
                    setState(() {
                      password = passwordValue;
                    });
                  },
                  obscureText: true,
                ),
                SizedBox(
                  height: 20,
                ),

                Text(
                  AppLocalizations.of(context)!.confirmPassword,
                  style: kBlackTextStyle,
                ),
                TextField(
                  decoration: kTextFieldDecoration,
                  obscureText: true,
                  onChanged: (passwordValue) {
                    if (password != passwordValue) {
                      //error TODO:
                    } else {
                      //ok TODO:
                    }
                  },
                ),

                SizedBox(
                  height: 25,
                ),
                Align(
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)!.byContinuingYouAgreeToTerms,
                      style: kSmallBlackTextStyle,
                    )), //TODO
                SizedBox(
                  height: 5,
                ),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    child: Text(AppLocalizations.of(context)!.signUp),
                    onPressed: () async {
                      try {
                        final newUser =
                            await _auth.createUserWithEmailAndPassword(
                                email: email, password: password);
                        if (newUser != null) {
                          Navigator.pushNamed(context, MainScreen.id);
                        }
                      } catch (e) {
                        print(e);
                      }
                    },
                    style: kButtonStyle,
                  ),
                ),


                //TODO: continue
              ],
            ),
          ),
        ),
      ),
    );
  }
}
