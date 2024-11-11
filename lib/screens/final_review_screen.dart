import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';

import '../dictionary.dart';

class FinalReviewScreen extends StatefulWidget {
  static String id = 'final_review_screen';
  const FinalReviewScreen({super.key});

  @override
  State<FinalReviewScreen> createState() => _FinalReviewScreenState();
}

class _FinalReviewScreenState extends State<FinalReviewScreen> {

  @override
  Widget build(BuildContext context) {
    var localization = Dictionary.getLocalization(context);
    return Scaffold(
      appBar: CustomAppBar(title: localization.reviews, isBackButton: false),
      body: PopScope(
        canPop: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('סיימנו!', style: kTopHeaderTextStyle,),
              Text('תודה שהקדשת מזמנך לשיפור השירות', style: kBlackHeaderTextStyle,),
              Icon(Icons.thumb_up_alt_outlined, color: kPastelYellow, size: 200,),
              SizedBox(height: 50),
              ElevatedButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), child: Text('לחזרה למסך הראשי'))
            ],
          ),
        ),
      )
    );
  }
}

