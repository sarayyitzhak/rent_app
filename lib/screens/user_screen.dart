import 'package:rent_app/screens/item_grid_screen.dart';
import 'package:rent_app/screens/profile_screen.dart';
import 'package:rent_app/screens/rental_history_screen.dart';
import 'package:rent_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/globals.dart';
import '../constants.dart';
import '../dictionary.dart';
import '../services/cloud_services.dart';
import '../widgets/cached_image.dart';
import '../widgets/icon_above_text.dart';
import 'edit_user_details_screen.dart';

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
    var localization = Dictionary.getLocalization(context);
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
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, EditUserDetailsScreen.id),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 30),
                  width: double.infinity,
                  child: Column(
                    children: [
                      CachedImage(
                        width: 70,
                        height: 70,
                        imageRef: getUserImageRef(userDetails.docRef, userDetails.photoID),
                        borderRadius: BorderRadius.circular(100),
                        errorIcon: Icons.person,
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
                        onPressed: () => Navigator.pushNamed(context, ItemGridScreen.id,
                            arguments: ItemGridScreenArguments(localization.wishlist, getUserFavoriteItems)),
                        child:
                            IconAboveText(icon: Icons.receipt_long_outlined, label: localization.wishlist, size: 40)),
                    TextButton(
                        onPressed: () => Navigator.pushNamed(context, RentalHistoryScreen.id),
                        child:
                            IconAboveText(icon: Icons.history_edu, label: 'היסטוריה', size: 40)),
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
