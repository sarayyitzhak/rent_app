import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/screens/item_requests_screen.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/custom_button.dart';

import '../dictionary.dart';


class RequestSubmittedScreen extends StatelessWidget {
  static String id = 'request_submitted_screen';
  const RequestSubmittedScreen({super.key});


  @override
  Widget build(BuildContext context) {
    var localization = Dictionary.getLocalization(context);
    return Scaffold(
      appBar: CustomAppBar(title: localization.myOrder, isBackButton: false,),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(localization.theRequestSentSuccessfully, style: kHeadersTextStyle),
            Icon(Icons.done_outline, color: kPastelYellow, size: 150,),
            Column(
              children: [
                CustomButton(title: localization.trackYourRequest, onPress: (){Navigator.pushNamed(context, ItemRequestsScreen.id);}, buttonStyle: kDarkButtonStyle,),
                CustomButton(title: localization.goBackToMainScreen, onPress: (){Navigator.of(context).popUntil((route) => route.isFirst);}, buttonStyle: kLightButtonStyle,),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
