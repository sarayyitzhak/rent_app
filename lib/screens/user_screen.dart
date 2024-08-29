import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/screens/welcome_screen.dart';
import 'package:rent_app/screens/wishlist_screen.dart';
import 'package:rent_app/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import '../constants.dart';
import '../main.dart';
import '../models/user.dart';

class UserScreen extends StatefulWidget {
  static String id = 'user_screen';

  UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _auth = FirebaseAuth.instance;
 //????
  final _firestore = FirebaseFirestore.instance;

  // late final userUid;
  late Future<dynamic> userData;
  var localization;

  // late Future<Map<String, dynamic>> userData = userServices.getUserData(userUid!);
  // UserServices userServices = UserServices(FirebaseAuth.instance, FirebaseFirestore.instance);

  void getUser() async {
    userDetails = await getUserDetailsByUid(userUid!);
  }


  @override
  Widget build(BuildContext context) {
    // getUser();

    var localization = AppLocalizations.of(context)!;
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: localization.myProfile,
          isBackButton: false,
        ),
        body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(30),
              width: double.infinity,
              child: Column(
                children: [
                  CircleAvatar(
                    child: Icon(
                      Icons.account_circle_rounded,
                      size: 40,
                    ),
                    backgroundColor: kLightYellow,
                    // radius: 20,
                  ),
                  Text(
                    userDetails.name,
                    style: kBlackHeaderTextStyle,
                  ), //TODO: add user details
                  Text(
                    userDetails.email,
                    style: kBlackTextStyle,
                  ),
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
                  TextButton(
                      onPressed: () {},
                      child: iconAboveText(
                          Icons.person_outline, localization.profile)),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, WishlistScreen.id);
                      },
                      child: iconAboveText(Icons.receipt_long_outlined,
                          localization.wishlist)),
                  TextButton(
                      onPressed: () {},
                      child: iconAboveText(
                          Icons.shopping_cart_outlined, localization.myItems)),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            buildButton(
                label: localization.notifications,
                icon: Icons.notifications_none,
                onPress: () {}),
            buildButton(
                label: localization.paymentMethod,
                icon: Icons.credit_card,
                onPress: () {}),
            buildButton(
                label: localization.settings,
                icon: Icons.settings_outlined,
                onPress: () {}),
            buildButton(
                label: localization.help,
                icon: Icons.help_outline,
                onPress: () {}),
            buildButton(
                label: localization.privacyPolicy,
                icon: Icons.key,
                onPress: () {}),
            buildButton(
                label: localization.logout,
                icon: Icons.logout,
                onPress: () {
                  _auth.signOut();
                  userUid = '';
                  Navigator.of(context).pushNamedAndRemoveUntil(WelcomeScreen.id,
                  (Route<dynamic> route) => false,);
                }),
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

TextButton buildButton(
    {required String label,
    required IconData icon,
    required VoidCallback onPress}) {
  return TextButton.icon(
    onPressed: onPress,
    label: Text(
      label,
      style: kBlackTextStyle,
    ),
    icon: CircleAvatar(
      child: Icon(icon),
      backgroundColor: kPastelYellow,
    ),
  );
}

Column iconAboveText(IconData icon, String label) {
  return Column(
    children: [
      Icon(
        icon,
        color: Colors.black54,
        size: 40,
      ),
      Text(
        label,
        style: kSmallBlackTextStyle,
      ),
    ],
  );
}
