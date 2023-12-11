import 'package:flutter/material.dart';

import '../models/OrderElement.dart';
import '../theme.dart';
import 'Comment.dart';
import 'LittleCard.dart';

class OrderLineElement extends StatelessWidget {
  const OrderLineElement({super.key, required this.orderElement});

  final OrderElement orderElement;

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
    Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LittleCard(
                  littleCardColor: customColors.primaryLight!,
                  leftMargin: 10.0,
                  text: "${orderElement.quantity}"),
              LittleCard(
                  littleCardColor: customColors.primaryLight!,
                  text: orderElement.articleAlpha),
              LittleCard(
                  littleCardColor: customColors.primaryLight!,
                  text: "${orderElement.articleNumber}"),
              LittleCard(
                //Shows the subAlpha code of the order if it exists
                littleCardColor: customColors.primaryLight!,
                empty: orderElement.articleSubAlpha.isEmpty,
                text: orderElement.articleSubAlpha,
              ),
              LittleCard(
                //Show the price of the extra if there is one
                littleCardColor: customColors.primaryLight!,
                empty: !orderElement.commentIsExtra,
                text: "${orderElement.extraPrice}€",
              ),
              LittleCard(
                //Unit price for the article
                  littleCardColor: customColors.primaryLight!,
                  flex: 3,
                  text: "${orderElement.articlePrice}€"),
              LittleCard(
                //Total price for the orderElement
                  littleCardColor: customColors.primaryLight!,
                  flex: 3,
                  rightMargin: 10.0,
                  text: "${orderElement.price}€"),
            ],
          ),
          Builder(builder: (context) {
            if (orderElement.comment.isNotEmpty) {
              return Comment(
                comment: orderElement.comment,
                isExtra: orderElement.commentIsExtra,
              );
            } else {
              return SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }
}