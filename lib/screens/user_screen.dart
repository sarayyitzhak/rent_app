import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/screens/grid_items_screen.dart';
import 'package:rent_app/screens/profile_screen.dart';
import 'package:rent_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import '../constants.dart';
import '../main.dart';
import '../services/cloud_services.dart';
import '../widgets/icon_above_text.dart';

class UserScreen extends StatefulWidget {
  static String id = 'user_screen';

  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late Future<dynamic> userData;
  var localization;

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: localization.myProfile,
          isBackButton: false,
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                width: double.infinity,
                child: Column(
                  children: [
                    const CircleAvatar(
                      backgroundColor: kLightYellow,
                      child: Icon(
                        Icons.account_circle_rounded,
                        size: 40,
                      ),
                      // radius: 20,
                    ),
                    Text(
                      userDetails.name,
                      style: kBlackHeaderTextStyle,
                    ), //TODO: add user details
                    Text(
                      getCurrentUser()!.email!,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.pushNamed(context, ProfileScreen.id),
                        child: IconAboveText(icon: Icons.person_outline, label: localization.profile, size: 40)),
                    TextButton(
                        onPressed: () => Navigator.pushNamed(context, GridItemsScreen.id,
                            arguments: GridItemsScreenArguments(localization.wishlist, getUserFavoriteItems)),
                        child:
                            IconAboveText(icon: Icons.receipt_long_outlined, label: localization.wishlist, size: 40)),
                    TextButton(
                        onPressed: () {},
                        child:
                            IconAboveText(icon: Icons.shopping_cart_outlined, label: localization.myItems, size: 40)),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              buildButton(label: localization.notifications, icon: Icons.notifications_none, onPress: () {}),
              buildButton(label: localization.paymentMethod, icon: Icons.credit_card, onPress: () {}),
              buildButton(label: localization.settings, icon: Icons.settings_outlined, onPress: () {}),
              buildButton(label: localization.help, icon: Icons.help_outline, onPress: () {}),
              buildButton(label: localization.privacyPolicy, icon: Icons.key, onPress: () {}),
              buildButton(
                  label: localization.logout,
                  icon: Icons.logout,
                  onPress: () {
                    signOut();
                    userUid = '';
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      WelcomeScreen.id,
                      (Route<dynamic> route) => false,
                    );
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

TextButton buildButton({required String label, required IconData icon, required VoidCallback onPress}) {
  return TextButton.icon(
    onPressed: onPress,
    label: Text(
      label,
      style: kBlackTextStyle,
    ),
    icon: CircleAvatar(
      backgroundColor: kPastelYellow,
      child: Icon(icon),
    ),
  );
}
