import 'package:flutter/material.dart';

import '../models/Article.dart';
import '../models/Promotion.dart';
import '../theme.dart';
import 'LittleCard.dart';

class PromotionLineLong extends StatelessWidget {
  const PromotionLineLong({super.key, required this.promotion, required this.linkedArticle});

  final Promotion promotion;
  final Article linkedArticle;

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
    Theme.of(context).extension<CustomColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            LittleCard(
                littleCardColor: customColors.secondary!,
                leftMargin: 10.0,
                flex: 6,
                text: promotion.name),
            LittleCard(
                littleCardColor: customColors.secondary!,
                flex: 2,
                text: "${linkedArticle.alpha}${linkedArticle.number}${linkedArticle.subAlpha != ""? linkedArticle.subAlpha : ""}"),
            LittleCard(
                littleCardColor: customColors.secondaryLight!,
                flex: 4,
                rightMargin: 10.0,
                text: "-${promotion.discountValue}€"),
          ],
        ),
      ],
    );
  }
}