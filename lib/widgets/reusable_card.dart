import 'package:flutter/material.dart';

class ReusableCard extends StatefulWidget {
  final Color color;
  final Widget cardChild;
  final Function()? onPress;
  bool isPressed = false;

  ReusableCard({super.key, required this.color, required this.cardChild, required this.onPress, this.isPressed = false});

  @override
  State<ReusableCard> createState() => _ReusableCardState();
}

class _ReusableCardState extends State<ReusableCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPress,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: widget.cardChild,
      ),
    );
  }
}
