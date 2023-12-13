import 'package:flutter/material.dart';

class QuaiTextContainer extends StatelessWidget {
  const QuaiTextContainer({
    super.key,
    required this.text,
    required this.color,
    this.marginLeft = 5,
    this.marginRight = 5,
    this.marginTop = 3,
    this.marginBottom = 2,
  });

  final String text;
  final Color color;

  final double marginLeft;
  final double marginRight;
  final double marginTop;
  final double marginBottom;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: marginLeft, right: marginRight, top:marginTop, bottom: marginBottom),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            text, textAlign: TextAlign.center, style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 22
          ),
          ),
        ),
      ),
    );
  }
}
