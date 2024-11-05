import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:rent_app/constants.dart';
import 'package:flutter/material.dart';

class RatingStarsRow extends StatefulWidget {
  var onChanged;

  RatingStarsRow({super.key, required this.onChanged});

  @override
  State<RatingStarsRow> createState() => _RatingStarsRowState();
}

class _RatingStarsRowState extends State<RatingStarsRow> {
  double rate = 0;
  @override
  Widget build(BuildContext context) {
    return RatingStars(
      value: rate,
      onValueChanged: (v) {
        setState(() {
          rate = v;
        });
        widget.onChanged(v);
      },
      starBuilder: (index, color) => Icon(
        Icons.star,
        color: color,
      ),
      starCount: 5,
      starSize: 20,
      valueLabelVisibility: false,
      // valueLabelColor: kActiveButtonColor,
      // valueLabelTextStyle: const TextStyle(
      //     color: Colors.white,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //     fontSize: 12.0),
      // valueLabelRadius: 10,
      maxValue: 5,
      starSpacing: 2,
      animationDuration: Duration(milliseconds: 1000),
      starOffColor: const Color(0xffe7e8ea),
      starColor: kActiveButtonColor,
    );
  }
}
