import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/models/condition.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/screens/final_review_screen.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/rating_stars.dart';
import '../models/item.dart';
import '../models/item_review.dart';
import '../models/user_review.dart';

class UserReviewScreen extends StatefulWidget {
  static String id = 'user_review_screen';
  final UserReviewScreenArguments args;
  const UserReviewScreen(this.args, {super.key});

  @override
  State<UserReviewScreen> createState() => _UserReviewScreenState();
}

class _UserReviewScreenState extends State<UserReviewScreen> {
  int? overallRate;
  int? serviceLevel;
  TextEditingController textController = TextEditingController();
  late UserReview userReview;

  @override
  Widget build(BuildContext context) {
    UserDetails user = widget.args.user;
    var localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(title: localization.reviews),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'מה דעתך הכללית על המשכיר?',
                        style: kBlackHeaderTextStyle,
                      ),
                      RatingStarsRow(onChanged: (v) => overallRate = v.toInt()),
                      SizedBox(height: 15),

                      Text(
                        'דרג את רמת השרותיות שלו (זמינות, עמידה בזמנים ועוד)',
                        style: kBlackHeaderTextStyle,
                      ),
                      RatingStarsRow(onChanged: (v) => serviceLevel = v.toInt()),
                      SizedBox(height: 15),
                    ],
                  ),
                  SizedBox(height: 30),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ספר לנו עוד',
                        style: kBlackTextStyle,
                      ),
                      Container(
                        height: 150,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: textController,
                          decoration: InputDecoration(
                            hintText: 'שיתוף פרטים על חווית ההשכרה שלך עם משכיר זה',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                          ),
                          maxLines: 8,
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                  SizedBox(height: 40),

                  ElevatedButton(onPressed: () {
                    if(overallRate != null || serviceLevel != null || textController.text.isNotEmpty){
                      addUserReview(user.docRef, overallRate, serviceLevel, textController.text);
                      Navigator.pushNamed(context, FinalReviewScreen.id);
                    } // else make then answer

                  }, child: Text('סיום'), style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.grey[200]),
                  ),),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UserReviewScreenArguments {
  final UserDetails user;
  UserReviewScreenArguments(this.user);
}
