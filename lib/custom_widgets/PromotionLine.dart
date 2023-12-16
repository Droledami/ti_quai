import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ti_quai/custom_widgets/SizedIconButton.dart';

import '../models/Article.dart';
import '../models/Promotion.dart';
import '../theme.dart';
import 'DismissibleBackground.dart';
import 'LittleCard.dart';

class PromotionLine extends StatelessWidget {
  const PromotionLine(
      {required super.key,
      required this.promotion, this.linkedArticle,
      required this.onDismissed})
      : assert(key != null, "Key is required for PromotionLineLong for its dismiss feature");

  final Promotion promotion;
  final Article? linkedArticle;

  final Function onDismissed;

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Dismissible(
        key: key!,
        background: DismissibleBackground(),
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
                    empty: linkedArticle == null,
                    text: linkedArticle != null ?
                        "${linkedArticle!.alpha}${linkedArticle!.number}${linkedArticle!.subAlpha != "" ? linkedArticle!.subAlpha : ""}" : ""),
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
