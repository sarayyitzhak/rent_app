import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/models/category.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/widgets/category_list_tile.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/scrollable_item_grid.dart';
import '../constants.dart';
import '../services/firebase_services.dart';
import '../widgets/custom_button.dart';
import '../widgets/text_and_text_field.dart';

class ProfileScreen extends StatefulWidget {
  static String id = 'profile_screen';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;
  // DateTime selectedDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: userDetails.name);
    emailController = TextEditingController(text: userDetails.email);
    phoneNumberController = TextEditingController(text: '0${userDetails.phoneNumber}');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  void onEditButtonPressed(){
    userDetails.name = nameController.text;
    userDetails.email = emailController.text;//TODO:how?
    userDetails.phoneNumber = int.parse(phoneNumberController.text);
    var data = userDetails.userAsMap();
    userDetails.userReference.update(data);
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    return SafeArea(child: Scaffold(
      appBar: CustomAppBar(title: localization.myProfile),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(alignment:Alignment.center, child: CircleAvatar(child: Icon(Icons.person, size: 30,), radius: 40,)),
              SizedBox.square(dimension: 15,),
              Align(alignment: Alignment.center, child: Text(userDetails.name, style: kBlackHeaderTextStyle,)),
              SizedBox.square(dimension: 20,),
              TextAndTextField(title: localization.fullName, controller: nameController,),
              TextAndTextField(title: localization.email, controller: emailController, keyboardType: TextInputType.emailAddress,),
              TextAndTextField(title: localization.mobileNumber, controller: phoneNumberController, keyboardType: TextInputType.phone),
              SizedBox(
                height: 25,
              ),
              SizedBox(
                height: 5,
              ),
              Center(
                child: CustomButton(title: 'ערוך', buttonStyle: kDarkButtonStyle, onPress: onEditButtonPressed,),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
