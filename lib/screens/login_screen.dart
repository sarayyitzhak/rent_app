import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/text_and_text_field.dart';
import 'package:rent_app/widgets/custom_button.dart';
import '../dictionary.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localization = Dictionary.getLocalization(context);

    void onLoginButtonPressed() async {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent user from closing the dialog
        builder: (context) => const Center(child: CircularProgressIndicator(color: kPastelYellow,)),
      );
      FocusScope.of(context).requestFocus(FocusNode());
      try {
        await login(emailController.text, passwordController.text);
      } catch (e) {
        print(e);
      }
      Navigator.pop(context);
      Navigator.of(context).pushNamedAndRemoveUntil(MainScreen.id,
            (Route<dynamic> route) => false, // This removes all previous routes
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(title: localization.login),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localization.welcome,
                  style: kBlackHeaderTextStyle,
                ),
                Text(
                  localization.pleaseEnterYourDetailsToProceed,
                  style: kSmallBlackTextStyle,
                ),
                const SizedBox(
                  height: 50,
                ),
                TextAndTextField(
                  title: localization.usernameOrEmail,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextAndTextField(
                  title: localization.password,
                  controller: passwordController,
                  isObscureText: true,
                ),
                const SizedBox(
                  height: 40,
                ),
                Center(
                  child: CustomButton(
                    title: localization.login,
                    buttonStyle: kDarkButtonStyle,
                    onPress: onLoginButtonPressed,
                  ),
                ),

                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: kBlackColor,
                    ),
                    onPressed: () {
                      //TODO
                    },
                    child: Text(localization.forgotPassword),
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
