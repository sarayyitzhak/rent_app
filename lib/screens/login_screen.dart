import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/widgets/TextAndTextField.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/navigateButton.dart';
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
    var localization = AppLocalizations.of(context)!;

    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: Text(localization.login),
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
              Text(localization.welcome, style: kBlackHeaderTextStyle,),
              Text(localization.pleaseEnterYourDetailsToProceed, style: kSmallBlackTextStyle,),
              SizedBox(
                height: 50,
              ),
              TextAndTextField(title: localization.usernameOrEmail, controller: emailController, keyboardType: TextInputType.emailAddress,),
              TextAndTextField(title: localization.password, controller: passwordController, isObscureText: true,),
              SizedBox(
                height: 20,
              ),
              Center(
                child: CustomButton(title: localization.login, buttonStyle: kDarkButtonStyle, onPress: () async {
                  try{
                    final user = await _auth.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
                    if(user != null){
                      Navigator.of(context).pushNamedAndRemoveUntil(MainScreen.id,
                            (Route<dynamic> route) => false, // This removes all previous routes
                      );
                    }
                  } catch (e) {
                    print(e);
                  }
                }, ),
              ),

              Center(
                child: TextButton(
                  child: Text(localization.forgotPassword),
                  style: TextButton.styleFrom(
                    foregroundColor: kBlackColor,
                  ),
                  onPressed: () {
                    //TODO
                  },
                ),
              ),
              //TODO: continue
            ],
          ),
        ),
      ),
    ),);
  }
}
