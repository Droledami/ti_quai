import 'package:flutter/material.dart';

import '../models/OrderElement.dart';
import '../theme.dart';
import 'LittleCard.dart';
import 'PromotionCard.dart';

class PromotionsSummary extends StatelessWidget {
  const PromotionsSummary(
      {super.key, required this.orderElements, required this.totalDiscount});

  final List<OrderElement> orderElements;
  final double totalDiscount;

  @override
  Widget build(BuildContext context) {
    CustomColors customColors = Theme.of(context).extension<CustomColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          runAlignment: WrapAlignment.end,
          direction: Axis.horizontal,
          children: orderElements.map((orderElement) {
            if (orderElement.hasPromotion && orderElement.promotion != null) {
              return PromotionCard(
                  promotionName: orderElement.promotion!.name,
                  discountValue: orderElement.promotion!.discountValue);
            } else if (orderElement.hasPromotion &&
                orderElement.promotion == null) {
              print(
                  "Error, a promotion has incorrectly set values : hasPromotion is true, yet promotion is null");
              return SizedBox();
            } else if (!orderElement.hasPromotion &&
                orderElement.promotion != null) {
              print(
                  "Warning, a promotion has incorrectly set values : hasPromotion is false, yet promotion has data");
              return PromotionCard(
                  promotionName: orderElement.promotion!.name,
                  discountValue: orderElement.promotion!.discountValue);
            } else {
              return SizedBox();
            }
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              //Offsets the other child to the end of the line
              flex: 8,
              child: SizedBox.shrink(),
            ),
            LittleCard(
              text: "-$totalDiscount€",
              flex: 3,
              littleCardColor: customColors.secondaryLight!,
              rightMargin: 10.0,
            )
          ],
        ),
      ],
    );
  }
}