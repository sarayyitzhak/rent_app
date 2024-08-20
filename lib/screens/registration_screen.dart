import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/widgets/TextAndTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/navigateButton.dart';
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
  late TextEditingController dateOfBirthController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneNumberController = TextEditingController();
    dateOfBirthController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    dateOfBirthController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(localization.createAccount),
          titleTextStyle: kTopHeaderTextStyle,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
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
                TextAndTextField(title: localization.fullName, controller: nameController,),
                TextAndTextField(title: localization.email, controller: emailController, keyboardType: TextInputType.emailAddress,),
                TextAndTextField(title: localization.mobileNumber, controller: phoneNumberController, keyboardType: TextInputType.phone),
                TextAndTextField(title: localization.dateOfBirth, controller: dateOfBirthController, keyboardType: TextInputType.datetime,),
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
                        _firestore.collection('users').doc(newUser.user?.uid).set({
                          'fullName': nameController.text,
                          'phoneNumber': phoneNumberController.text,
                          'DateofBirth': dateOfBirthController.text,
                        });
                        Navigator.of(context).pushNamedAndRemoveUntil(MainScreen.id,
                              (Route<dynamic> route) => false, // This removes all previous routes
                        );
                      }
                    } catch (e) {
                      print(e);//TODO
                    }
                  },),
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
