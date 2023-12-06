
import 'package:flutter/material.dart';

import '../theme.dart';

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
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.00, -1.00),
          end: const Alignment(0, 1),
          stops: const [0.5, 8.0],
          colors: [
            customColors.primaryLight!,
            customColors.primary!,
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
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