import 'package:flutter/material.dart';
import '../constants.dart';

class IconAboveText extends StatelessWidget {
  IconData icon;
  String label;
  double? size;
  IconAboveText({super.key, required this.icon, required this.label, this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.black54,
          size: size,
        ),
        Text(
          label,
          style: kSmallBlackTextStyle,
        ),
      ],
    );
  }
}
