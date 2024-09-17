import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:url_launcher/url_launcher.dart';

class DialIconButton extends StatelessWidget {
  String phoneNumber;
  DialIconButton({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        padding: EdgeInsets.all(10),
        constraints: BoxConstraints(),
        style: const ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
        ),
        onPressed: () async {
          final Uri phoneUri = Uri(
            scheme: 'tel',
            path: phoneNumber,
          );
          if (await canLaunchUrl(phoneUri)) {
            await launchUrl(phoneUri);
          } else {
            throw 'Could not launch $phoneNumber';
          }
        },
        icon: CircleAvatar(
          child: Icon(
            Icons.local_phone_rounded,
            size: 30,
            color: kWhiteColor,
          ),
          radius: 20,
          backgroundColor: kActiveButtonColor,
        ));
  }
}
