import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/models/condition.dart';
import 'package:rent_app/screens/user_review_screen.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/rating_stars.dart';
import '../models/item.dart';
import '../models/item_review.dart';

class ItemReviewScreen extends StatefulWidget {
  static String id = 'item_review_screen';
  final ItemReviewScreenArguments args;
  const ItemReviewScreen(this.args, {super.key});

  @override
  State<ItemReviewScreen> createState() => _ItemReviewScreenState();
}

class _ItemReviewScreenState extends State<ItemReviewScreen> {
  int? overallRate;
  int? valueForPrice;
  int? compatibility;
  TextEditingController textController = TextEditingController();
  Condition? condition;
  late ItemReview itemReview;

  @override
  Widget build(BuildContext context) {
    Item item = widget.args.item;
    var localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(title: localization.reviews),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'מה דעתך הכללית על המוצר?',
                      style: kBlackHeaderTextStyle,
                    ),
                    RatingStarsRow(onChanged: (v) => overallRate = v.toInt()),
                    SizedBox(height: 15),

                    Text(
                      'מה התמורה למחיר?',
                      style: kBlackHeaderTextStyle,
                    ),
                    RatingStarsRow(onChanged: (v) => valueForPrice = v.toInt()),
                    SizedBox(height: 15),

                    Text(
                      'כמה המוצר תואם למודעה?',
                      style: kBlackHeaderTextStyle,
                    ),
                    RatingStarsRow(onChanged: (v) => compatibility = v.toInt()),
                  ],
                ),
                SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
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
                            hintText: 'שיתוף פרטים על חווית ההשכרה שלך עם מוצר זה',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                          ),
                          maxLines: 8,
                        ),
                      ),

                      SizedBox(height: 30),

                      Text(
                        'איך היית מתאר את מצב המוצר?',
                        style: kBlackHeaderTextStyle,
                      ),
                      Wrap(
                        spacing: 10,
                        children: Condition.values
                            .map((c) => ElevatedButton(
                                  child: Text(c.getTitle(localization)),
                                  style: ButtonStyle(
                                      backgroundColor: c == condition ? WidgetStatePropertyAll(Colors.grey[400]) : WidgetStatePropertyAll(Colors.grey[200]),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      condition = c;
                                    });
                                  },
                                ))
                            .toList(),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 40),
                
                ElevatedButton(onPressed: () async {
                  if(overallRate != null || valueForPrice != null || compatibility != null || condition != null || textController.text.isNotEmpty){
                    addItemReview(item.docRef, overallRate, valueForPrice, compatibility, condition, textController.text);
                    Navigator.pushNamed(context, UserReviewScreen.id, arguments: UserReviewScreenArguments(await getUserByID(item.contactUserID)));
                  } // else make then answer

                }, child: Text('המשך'), style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.grey[200]),
                ),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ItemReviewScreenArguments {
  final Item item;
  ItemReviewScreenArguments(this.item);
}
