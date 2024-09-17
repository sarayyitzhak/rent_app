import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';

class CustomButton extends StatelessWidget {
  String title;
  ButtonStyle buttonStyle;
  Function()? onPress;
  CustomButton({super.key, required this.title, required this.onPress, this.buttonStyle = kDarkButtonStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          child: Text(
            title,
          ),
          onPressed: onPress,
          // style: buttonStyle,
          style: ElevatedButton.styleFrom(
            foregroundColor: kGreyColor,
            backgroundColor: kPastelYellow,
            elevation: 7,
            textStyle: kButtonTextStyle
          ),
        ),
      ),
    );
  }
}
