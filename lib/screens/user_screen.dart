import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import '../constants.dart';

class UserScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  static String id = 'user_screen';
  UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(AppLocalizations.of(context)!.myProfile, style: kTopHeaderTextStyle,),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(30),
                width: double.infinity,
                child: const Column(
                  children: [
                    CircleAvatar(
                      child: Icon(Icons.account_circle_rounded, size: 40,),
                      backgroundColor: kLightYellow,
                      // radius: 20,
                    ),
                    Text('Saray Yitzhak', style: kBlackHeaderTextStyle,), //TODO: add user details

                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kPastelYellow,
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () {}, child: iconAboveText(Icons.person_outline, AppLocalizations.of(context)!.profile)),
                    TextButton(onPressed: () {}, child: iconAboveText(Icons.receipt_long_outlined, AppLocalizations.of(context)!.wishlist)),
                    TextButton(onPressed: () {}, child: iconAboveText(Icons.shop_2_outlined, AppLocalizations.of(context)!.myOrders)),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              buildButton(label: AppLocalizations.of(context)!.notifications, icon: Icons.notifications_none, onPress: (){}),
              buildButton(label: AppLocalizations.of(context)!.paymentMethod, icon: Icons.credit_card, onPress: (){}),
              buildButton(label: AppLocalizations.of(context)!.settings, icon: Icons.settings_outlined, onPress: (){}),
              buildButton(label: AppLocalizations.of(context)!.help, icon: Icons.help_outline, onPress: (){}),
              buildButton(label: AppLocalizations.of(context)!.privacyPolicy, icon: Icons.key, onPress: (){}),
              buildButton(label: AppLocalizations.of(context)!.logout, icon: Icons.logout, onPress: (){ _auth.signOut();}),
            ],
          ),
        ),
      ),
    );
  }
}

Map<String, IconData> buttonsTextAndIcon = {
  'Notification': Icons.notifications_none,
  'Payment Method': Icons.credit_card,
  'Settings': Icons.settings_outlined,
  'Help': Icons.help_outline,
  'Privacy Policy': Icons.key,
  'Logout': Icons.logout,
};

//models

TextButton buildButton({required String label, required IconData icon, required VoidCallback onPress}) {
  return TextButton.icon(onPressed: onPress, label: Text(label, style: kBlackTextStyle,), icon: CircleAvatar(child: Icon(icon), backgroundColor: kPastelYellow,),);
}

Column iconAboveText(IconData icon, String label){
  return Column(
    children: [
      Icon(icon, color: Colors.black54, size: 40,),
      Text(label, style: kSmallBlackTextStyle,),
    ],
  );
}