import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ti_quai/custom_widgets/SizedIconButton.dart';

import '../models/Article.dart';
import '../models/Promotion.dart';
import '../theme.dart';
import 'LittleCard.dart';

class PromotionLineLong extends StatelessWidget {
  const PromotionLineLong(
      {required super.key,
      required this.promotion,
      required this.linkedArticle,
      required this.onDismissed})
      : assert(key != null, "Key is required for PromotionLineLong for its dismiss feature");

  final Promotion promotion;
  final Article linkedArticle;

  final Function onDismissed;

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Dismissible(
        key: key!,
        background: Container(
          color: Colors.red,
          child: Row(
            children: [
              Icon(Icons.delete),
              Expanded(flex: 8,child: SizedBox.shrink()),
              Icon(Icons.delete),
            ],
          ),
        ),
        onDismissed: (dismissDirection) {
          onDismissed();
        },
        child: Column(
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
                    text:
                        "${linkedArticle.alpha}${linkedArticle.number}${linkedArticle.subAlpha != "" ? linkedArticle.subAlpha : ""}"),
                LittleCard(
                    littleCardColor: customColors.secondaryLight!,
                    flex: 4,
                    rightMargin: 10.0,
                    text: "-${promotion.discountValue}€"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
