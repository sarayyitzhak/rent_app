import 'dart:io';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/dictionary.dart';
import 'package:rent_app/globals.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/utils.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import '../constants.dart';
import '../dialogs/select_image_dialog.dart';
import '../services/cloud_services.dart';
import '../widgets/cached_image.dart';
import '../widgets/custom_button.dart';
import '../widgets/text_and_text_field.dart';

class EditUserDetailsScreen extends StatefulWidget {
  static String id = 'edit_user_details_screen';

  const EditUserDetailsScreen({super.key});

  @override
  State<EditUserDetailsScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<EditUserDetailsScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneNumberController;
  late bool _showPhoneNumber;

  void onEditButtonPressed() {
    updateUserDetails(nameController.text, int.parse(phoneNumberController.text), _showPhoneNumber);

    userDetails.name = nameController.text;
    userDetails.phoneNumber = int.parse(phoneNumberController.text);
    userDetails.showPhoneNumber = _showPhoneNumber;

    Navigator.pop(context);
  }

  Future<void> _onImagePicked(File file) async {
    deleteFile(getUserImageRef(userDetails.docRef, userDetails.photoID));

    String newPhotoID = generateRandomString(4);
    userDetails.photoID = newPhotoID;

    await updateUserPhotoID(userDetails.docRef, newPhotoID);

    await uploadFile(getUserImageRef(userDetails.docRef, newPhotoID), file);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: userDetails.name);
    phoneNumberController = TextEditingController(text: '0${userDetails.phoneNumber}');
    _showPhoneNumber = userDetails.showPhoneNumber;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localization = Dictionary.getLocalization(context);
    return Scaffold(
      appBar: CustomAppBar(title: localization.myProfile),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => SelectImageDialog(context).pickImage(_onImagePicked),
                child: Center(
                  child: CachedImage(
                    width: 80,
                    height: 80,
                    imageRef: getUserImageRef(userDetails.docRef, userDetails.photoID),
                    borderRadius: BorderRadius.circular(100),
                    errorIcon: Icons.person,
                  ),
                ),
              ),
              const SizedBox.square(
                dimension: 15,
              ),
              Align(
                  alignment: Alignment.center,
                  child: Text(
                    userDetails.name,
                    style: kBlackHeaderTextStyle,
                  )),
              const SizedBox.square(
                dimension: 20,
              ),
              TextAndTextField(
                title: localization.fullName,
                controller: nameController,
              ),
              const SizedBox(
                height: 20,
              ),
              TextAndTextField(
                  title: localization.mobileNumber,
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone),
              GestureDetector(
                  onTap: () {
                    setState(() {
                      _showPhoneNumber = !_showPhoneNumber;
                    });
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        value: _showPhoneNumber,
                        onChanged: (bool? value) {
                          setState(() {
                            _showPhoneNumber = value ?? false;
                          });
                        },
                      ),
                      Text(
                        localization.show_phone_number,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: CustomButton(
                  title: localization.edit,
                  buttonStyle: kDarkButtonStyle,
                  onPress: onEditButtonPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
