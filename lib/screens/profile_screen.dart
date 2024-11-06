import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/main.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import '../constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/text_and_text_field.dart';

class ProfileScreen extends StatefulWidget {
  static String id = 'profile_screen';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneNumberController;
  // DateTime selectedDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: userDetails.name);
    phoneNumberController = TextEditingController(text: '0${userDetails.phoneNumber}');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  void onEditButtonPressed(){
    userDetails.name = nameController.text;
    userDetails.phoneNumber = int.parse(phoneNumberController.text);
    var data = userDetails.userAsMap();
    userDetails.docRef.update(data);
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
              const Align(alignment:Alignment.center, child: CircleAvatar(radius: 40,child: Icon(Icons.person, size: 30,),)),
              const SizedBox.square(dimension: 15,),
              Align(alignment: Alignment.center, child: Text(userDetails.name, style: kBlackHeaderTextStyle,)),
              const SizedBox.square(dimension: 20,),
              TextAndTextField(title: localization.fullName, controller: nameController,),
              TextAndTextField(title: localization.mobileNumber, controller: phoneNumberController, keyboardType: TextInputType.phone),
              const SizedBox(
                height: 25,
              ),
              const SizedBox(
                height: 5,
              ),
              Center(
                child: CustomButton(title: localization.edit, buttonStyle: kDarkButtonStyle, onPress: onEditButtonPressed,),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
