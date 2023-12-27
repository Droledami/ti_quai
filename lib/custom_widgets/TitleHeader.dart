import 'package:flutter/material.dart';

import '../custom_materials/decoration_functions.dart';
import '../custom_materials/theme.dart';

class TitleHeader extends StatelessWidget {
  const TitleHeader({
    super.key,
    required this.customColors,
    required this.title
  });

  final CustomColors customColors;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      height: 55,
      decoration: buildAppBarDecoration(customColors),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}