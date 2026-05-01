import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/screens/final_review_screen.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/rating_stars.dart';
import '../dictionary.dart';
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
  int? availabilityLevel;
  int? punctualityLevel;
  TextEditingController textController = TextEditingController();
  late UserReview userReview;

  @override
  Widget build(BuildContext context) {
    UserDetails user = widget.args.user;
    var localization = Dictionary.getLocalization(context);
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
                      const Text(
                        'מה דעתך הכללית על המשכיר?',
                        style: kBlackHeaderTextStyle,
                      ),
                      RatingStarsRow(onChanged: (v) => overallRate = v.toInt()),
                      const SizedBox(height: 15),
                      const Text(
                        'מה רמת הזמינות שלו?',
                        style: kBlackHeaderTextStyle,
                      ),
                      RatingStarsRow(
                          onChanged: (v) => availabilityLevel = v.toInt()),
                      const SizedBox(height: 15),
                      const Text(
                        'עד כמה הוא עמד בזמנים שקבעתם?',
                        style: kBlackHeaderTextStyle,
                      ),
                      RatingStarsRow(
                          onChanged: (v) => punctualityLevel = v.toInt()),
                      const SizedBox(height: 15),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ספר לנו עוד',
                        style: kBlackTextStyle,
                      ),
                      Container(
                        height: 150,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: textController,
                          decoration: const InputDecoration(
                            hintText:
                                'שיתוף פרטים על חווית ההשכרה שלך עם משכיר זה',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                          ),
                          maxLines: 8,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      if (overallRate != null ||
                          availabilityLevel != null ||
                          punctualityLevel != null ||
                          textController.text.isNotEmpty) {
                        addUserReview(
                            user.docRef,
                            overallRate,
                            availabilityLevel,
                            punctualityLevel,
                            textController.text);
                        Navigator.pushNamed(context, FinalReviewScreen.id);
                      } // else make then answer
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.grey[200]),
                    ),
                    child: const Text('סיום'),
                  ),
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
