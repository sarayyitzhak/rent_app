import 'package:flutter/material.dart';

class ReusableCard extends StatefulWidget {
  final Color color;
  final Widget cardChild;
  final Function()? onPress;
  bool isPressed = false;

  ReusableCard({required this.color, required this.cardChild, required this.onPress, this.isPressed = false});

  @override
  State<ReusableCard> createState() => _ReusableCardState();
}

class _ReusableCardState extends State<ReusableCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPress,
      child: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.all(10),
        child: widget.cardChild,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
