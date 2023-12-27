import 'package:flutter/material.dart';

class TextDivider extends StatelessWidget {
  const TextDivider({
    super.key,
    required this.text,
    required this.color,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w500,
    this.endIndent = 10,
  });

  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 5),
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
        ),
        Divider(
          height: 2,
          thickness: 3,
          indent: 10,
          endIndent: endIndent,
          color: color,
        ),
        SizedBox(
          height: 4,
        ),
      ],
    );
  }
}