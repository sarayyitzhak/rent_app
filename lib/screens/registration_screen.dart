import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/widgets/text_and_text_field.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/custom_button.dart';
import '../dictionary.dart';
import 'main_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
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

  Future<void> onRegisterButtonPressed() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password confirmation failed')),
      );
      return;
    }

    if (phoneNumberController.text.trim().isEmpty ||
        int.tryParse(phoneNumberController.text.trim()) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from closing the dialog
      builder: (context) => const Center(child: CircularProgressIndicator(color: kPastelYellow,)),
    );
    FocusScope.of(context).requestFocus(FocusNode());
    bool isSuccess = false;
    try {
      await createNewUser(emailController.text, passwordController.text, nameController.text, phoneNumberController.text);
      isSuccess = true;
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    }
    if (mounted) {
      Navigator.pop(context);
    }
    if (isSuccess && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        MainScreen.id,
            (Route<dynamic> route) => false, // This removes all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var localization = Dictionary.getLocalization(context);
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
                TextAndTextField(
                  title: localization.fullName,
                  controller: nameController,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextAndTextField(
                  title: localization.email,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextAndTextField(
                    title: localization.mobileNumber,
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone),
                const SizedBox(
                  height: 20,
                ),
                // TextAndTextField(title: localization.dateOfBirth, controller: dateOfBirthController, keyboardType: TextInputType.datetime,),
                //
                //
                // TextButton(onPressed: () => _selectDate(context), child: Text('date')),
                // InputDatePickerFormField(firstDate: DateTime(1930), lastDate: DateTime(2024), ),
                //
                // DatePickerDialog(firstDate: DateTime(1930), lastDate: DateTime(2024)),
                TextAndTextField(
                  title: localization.password,
                  controller: passwordController,
                  isObscureText: true,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextAndTextField(
                  title: localization.confirmPassword,
                  controller: confirmPasswordController,
                  isObscureText: true,
                ),
                const SizedBox(
                  height: 45,
                ),
                Align(
                    alignment: Alignment.center,
                    child: Text(
                      localization.byContinuingYouAgreeToTerms,
                      style: kSmallBlackTextStyle,
                    )), //TODO
                const SizedBox(
                  height: 5,
                ),
                Center(
                  child: CustomButton(
                    title: localization.signUp,
                    buttonStyle: kDarkButtonStyle,
                    onPress: onRegisterButtonPressed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
