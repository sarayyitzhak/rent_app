import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';

class TextAndTextField extends StatelessWidget {
  String title;
  TextEditingController controller;
  TextInputType keyboardType;
  bool isObscureText;
  TextAndTextField({super.key, required this.title, required this.controller, this.keyboardType = TextInputType.text, this.isObscureText = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: kBlackTextStyle,
        ),
        TextField(
          decoration: kTextFieldDecoration,
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.next,
          obscureText: isObscureText,
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
