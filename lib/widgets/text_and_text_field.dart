import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';

class TextAndTextField extends StatelessWidget {
  String title;
  TextEditingController controller;
  TextInputType keyboardType;
  bool isObscureText;
  Function()? onTapped;
  int? maxLines;
  TextInputAction textInputAction;
  bool textCapitalization;
  TextAndTextField({super.key, required this.title, required this.controller, this.keyboardType = TextInputType.text, this.isObscureText = false, this.onTapped, this.maxLines = 1, this.textInputAction = TextInputAction.next, this.textCapitalization = false});

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
          onTap: onTapped,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization ? TextCapitalization.sentences : TextCapitalization.none,
          minLines: 1,
          textInputAction: textInputAction,
          obscureText: isObscureText,
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
