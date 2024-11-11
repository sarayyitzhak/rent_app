import 'package:flutter/material.dart';

import '../constants.dart';

class RatingStarsWidget extends StatelessWidget {
  double rate;
  double? size;
  TextStyle? textStyle;
  RatingStarsWidget({super.key, required this.rate, this.size, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.star_rounded,
          color: kActiveButtonColor,
          size: size,
        ),
        Text(
          rate.toStringAsFixed(1),
          style: textStyle ?? kSmallBlackTextStyle,
        ),
      ],
    );
  }
}
