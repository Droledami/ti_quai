import 'package:flutter/material.dart';

import '../theme.dart';

class PromotionCard extends StatelessWidget {
  const PromotionCard(
      {super.key, required this.promotionName, required this.discountValue});

  final String promotionName;
  final double discountValue;

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
    Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 0, top: 3, bottom: 2),
      child: Container(
        width: 120,
        padding: EdgeInsets.only(right: 3),
        decoration: BoxDecoration(
          color: customColors.secondary,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.only(left: 3, right: 3),
              decoration: BoxDecoration(
                color: customColors.secondaryLight,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                "-$discountValue€",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Text(
                promotionName,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}