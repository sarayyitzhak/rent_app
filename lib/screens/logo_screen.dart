import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'home_screen.dart';
import 'main_screen.dart';
import 'user_screen.dart';


class LogoScreen extends StatelessWidget {
  static String id = 'logo_screen';
  const LogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              Text('BORRO', style: TextStyle(color: Colors.white, fontSize: 60,letterSpacing: 1, fontWeight: FontWeight.bold),),
            ],
          ),
        ),
      ),
    );
  }
}
