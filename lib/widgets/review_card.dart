import 'package:flutter/material.dart';
import 'package:rent_app/models/item_review.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/utils.dart';
import 'package:rent_app/widgets/rating_stars_widget.dart';
import '../constants.dart';
import 'cached_image.dart';

class ReviewCard extends StatelessWidget {
  final review;
  ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
      decoration: BoxDecoration(
        color: kPastelYellowOpacity,
        borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder(
                      future: getUserByID(review.userID),
                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if(snapshot.hasData){
                          UserDetails publisher = snapshot.data;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              children: [
                                CachedImage(
                                  width: 50,
                                  height: 50,
                                  imageRef: getUserImageRef(publisher.docRef, publisher.photoID),
                                  borderRadius: BorderRadius.circular(100),
                                  errorIcon: Icons.person,
                                ),
                                SizedBox(width: 15,),
                                Text(publisher.name, style: kBlackHeaderTextStyle,),
                              ],
                            ),
                          );
                        }
                        else {
                          return Text('');
                        }
                      },
                  ),
                  SizedBox(width: 250, child: Text(review.text.toString(), softWrap: true, overflow: TextOverflow.visible, maxLines: 5,)),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(getDifferenceInTimeAsString(context, review.createdAt), style: TextStyle(color: Colors.black45),),
              ),
              if(review.overallRate != null)
                RatingStarsWidget(rate: review.overallRate!.toDouble())
            ],
          ),
        ],
      ),
    );
  }
}
