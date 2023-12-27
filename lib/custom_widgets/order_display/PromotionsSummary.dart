import 'package:flutter/material.dart';

import '../../models/OrderElement.dart';
import '../../models/Promotion.dart';
import '../../custom_materials/theme.dart';
import '../LittleCard.dart';
import 'PromotionCard.dart';

class PromotionsSummary extends StatelessWidget {
  const PromotionsSummary(
      {super.key, required this.orderElements, required this.totalDiscount, required this.unlinkedPromotions});

  final List<OrderElement> orderElements;
  final List<Promotion> unlinkedPromotions;
  final double totalDiscount;

  @override
  Widget build(BuildContext context) {
    List<Promotion> fullListOfPromotions = List<Promotion>.from(unlinkedPromotions);
    for (var orderElement in orderElements) {
      if(orderElement.promotion != null && orderElement.hasPromotion){
      fullListOfPromotions.add(orderElement.promotion!);
      }else if(orderElement.hasPromotion && orderElement.promotion == null){
        print(
            "Error, a promotion has incorrectly set values : hasPromotion is true, yet promotion is null");
      }else if(!orderElement.hasPromotion && orderElement.promotion != null){
        print(
            "Warning, a promotion has incorrectly set values : hasPromotion is false, yet promotion has data");
        fullListOfPromotions.add(orderElement.promotion!);
      }
    }

    CustomColors customColors = Theme.of(context).extension<CustomColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          runAlignment: WrapAlignment.end,
          direction: Axis.horizontal,
          children: fullListOfPromotions.map((promotion) {
              return PromotionCard(
                  promotionName: promotion.name,
                  discountValue: promotion.discountValue);

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