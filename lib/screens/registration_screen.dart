import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/widgets/text_and_text_field.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/custom_button.dart';
import 'main_screen.dart';


class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  // DateTime selectedDate = DateTime.now();


  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneNumberController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //       context: context,
  //       initialDate: selectedDate,
  //       firstDate: DateTime(1930),
  //       lastDate: DateTime.now());
  //   if (picked != null && picked != selectedDate) {
  //     setState(() {
  //       selectedDate = picked;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(title: localization.createAccount),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextAndTextField(title: localization.fullName, controller: nameController,),
                TextAndTextField(title: localization.email, controller: emailController, keyboardType: TextInputType.emailAddress,),
                TextAndTextField(title: localization.mobileNumber, controller: phoneNumberController, keyboardType: TextInputType.phone),
                // TextAndTextField(title: localization.dateOfBirth, controller: dateOfBirthController, keyboardType: TextInputType.datetime,),
                //
                //
                // TextButton(onPressed: () => _selectDate(context), child: Text('date')),
                // InputDatePickerFormField(firstDate: DateTime(1930), lastDate: DateTime(2024), ),
                //
                // DatePickerDialog(firstDate: DateTime(1930), lastDate: DateTime(2024)),
                TextAndTextField(title: localization.password, controller: passwordController, isObscureText: true,),
                TextAndTextField(title: localization.confirmPassword, controller: confirmPasswordController, isObscureText: true,),
                SizedBox(
                  height: 25,
                ),
                Align(
                    alignment: Alignment.center,
                    child: Text(
                      localization.byContinuingYouAgreeToTerms,
                      style: kSmallBlackTextStyle,
                    )), //TODO
                SizedBox(
                  height: 5,
                ),
                Center(
                  child: CustomButton(title: localization.signUp, buttonStyle: kDarkButtonStyle, onPress: () async {
                    try {
                      if(passwordController.text != confirmPasswordController.text){
                        throw 'password confirmation failed'; //TODO
                      }
                      final newUser =
                      await _auth.createUserWithEmailAndPassword(
                          email: emailController.text, password: passwordController.text);
                      if (newUser != null) {
                        userUid = newUser.user?.uid;
                        DocumentReference userReference = _firestore.collection('users').doc(userUid);
                        userDetails = UserDetails(userReference: userReference, name: nameController.text, email: emailController.text, phoneNumber: int.parse(phoneNumberController.text), items: [], wishlist: [], chats: []);
                        userReference.set(userDetails.userAsMap());
                        Navigator.of(context).pushNamedAndRemoveUntil(MainScreen.id,
                              (Route<dynamic> route) => false, // This removes all previous routes
                        );
                      }
                    } catch (e) {
                      print(e);//TODO
                    }
                  },),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
