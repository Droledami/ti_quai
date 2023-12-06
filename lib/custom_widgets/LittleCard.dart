

import 'package:flutter/material.dart';

class LittleCard extends StatelessWidget {
  const LittleCard(
      {super.key,
        this.leftMargin = 3,
        this.rightMargin = 0,
        this.flex = 1,
        this.empty = false,
        this.text = "",
        this.height = 20,
        this.fontSize = 16,
        this.fontWeight = FontWeight.w900,
        required this.littleCardColor});

  final double leftMargin;
  final double rightMargin;
  final int flex;
  final bool empty;
  final String text;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final Color littleCardColor;

  @override
  Widget build(BuildContext context) {
    if (empty) {
      return Expanded(
        // because of flex Expanded will take the same space as if there were something
        child: Padding(
          padding: EdgeInsets.only(left: leftMargin, right: rightMargin),
          child: SizedBox(),
        ),
      );
    }
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.only(left: leftMargin, right: rightMargin),
        child: Container(
          height: height,
          padding: EdgeInsets.only(left: 2, right: 2, top: 3, bottom: 0),
          decoration: BoxDecoration(
            color: littleCardColor,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.clip,
            softWrap: false,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: fontWeight, height: 1, fontSize: fontSize),
          ),
        ),
      ),
    );
  }
}