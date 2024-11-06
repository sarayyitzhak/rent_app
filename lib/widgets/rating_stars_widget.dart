import 'package:flutter/material.dart';

import '../constants.dart';

class RatingStarsWidget extends StatelessWidget {
  double rate;
  RatingStarsWidget({super.key, required this.rate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.star_rounded,
          color: kActiveButtonColor,
        ),
        Text(
          rate.toStringAsFixed(1),
          style: kSmallBlackTextStyle,
        ),
      ],
    );
  }
}
