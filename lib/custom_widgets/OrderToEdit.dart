import 'package:flutter/material.dart';

import '../enums/ArticleType.dart';
import '../models/CustomerOrder.dart';
import '../theme.dart';
import 'GreatTotal.dart';
import 'LittleCard.dart';
import 'OrderHeader.dart';
import 'OrderLineElement.dart';
import 'OthersOrderLineElement.dart';
import 'PromotionLineLong.dart';
import 'TextDivider.dart';

class OrderToEdit extends StatefulWidget {
  const OrderToEdit({super.key, required this.order});

  final CustomerOrder order;

  @override
  State<OrderToEdit> createState() => _OrderToEditState();
}

class _OrderToEditState extends State<OrderToEdit> {
  bool hasOther = false;

  @override
  Widget build(BuildContext context) {
    final hasPromotion = widget.order.hasAnyPromotions;
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: customColors.cardQuarterTransparency!,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            OrderHeader(
              tableNumber: widget.order.tableNumber,
              articleNumber: widget.order.orderElements.length,
              orderDate: widget.order.date,
            ),
            TextDivider(text: "Menu", color: customColors.tertiary!),
            Column(
                children: widget.order.orderElements.map((orderElement) {
              if (orderElement.articleType == ArticleType.menu) {
                return OrderLineElement(orderElement: orderElement);
              } else {
                return SizedBox.shrink();
              }
            }).toList()),
            AddButton(color: customColors.primary!, spreadColor: customColors.primaryDark!,),
            Column(
              children: [
                Builder(builder: (context) {
                  if (hasOther) {
                    return TextDivider(
                        text: "Autres", color: customColors.tertiary!);
                  } else {
                    return SizedBox.shrink();
                  }
                }),
                Column(
                    children: widget.order.orderElements.map((orderElement) {
                  if (orderElement.articleType == ArticleType.other) {
                    if (!hasOther) hasOther = true;
                    return OthersOrderLineElement(
                      productName: orderElement.articleName,
                      productPrice: orderElement.articlePrice,
                      quantity: orderElement.quantity,
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }).toList()),
              ],
            ),
            Column(
              children: [
                Builder(builder: (context) {
                  if (hasPromotion) {
                    return Column(
                      children: [
                        TextDivider(
                            text: "Promotions", color: customColors.tertiary!),
                        Row(
                          children: [
                            LittleCard(
                                littleCardColor: customColors.secondary!,
                                leftMargin: 10.0,
                                height: 30,
                                flex: 6,
                                text: "Promotion"),
                            LittleCard(
                                littleCardColor: customColors.secondary!,
                                flex: 2,
                                fontSize: 13,
                                maxLines: 2,
                                height: 30,
                                text: "Article \n associé"),
                            LittleCard(
                                littleCardColor: customColors.secondaryLight!,
                                height: 30,
                                flex: 4,
                                rightMargin: 10.0,
                                text: "Réduction"),
                          ],
                        ),
                        SizedBox(height: 15),
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),
                Column(
                  children: widget.order.orderElements.map((orderElement) {
                    if (orderElement.hasPromotion && orderElement.promotion != null) {
                      return PromotionLineLong(promotion: orderElement.promotion!, linkedArticle: orderElement.article);
                    } else if (orderElement.hasPromotion &&
                        orderElement.promotion == null) {
                      print(
                          "Error, a promotion has incorrectly set values : hasPromotion is true, yet promotion is null");
                      return SizedBox();
                    } else if (!orderElement.hasPromotion &&
                        orderElement.promotion != null) {
                      print(
                          "Warning, a promotion has incorrectly set values : hasPromotion is false, yet promotion has data");
                      return PromotionLineLong(promotion: orderElement.promotion!, linkedArticle: orderElement.article);
                    } else {
                      return SizedBox();
                    }
                  }).toList(),
                ),
              ],
            ),
            AddButton(color: customColors.secondary!, spreadColor: customColors.secondaryLight!),
            GreatTotal(
                paymentMethod: widget.order.paymentMethod,
                totalPrice: widget.order.totalPrice),
          ],
        ),
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  const AddButton({
    super.key,
    required this.color,
    required this.spreadColor
  });

  final Color color;
  final Color spreadColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, top: 5),
      child: Container(
        width: 90,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
                color: Colors.black45,
                offset: Offset.fromDirection(1, 4),
                blurStyle: BlurStyle.normal,
                blurRadius: 4)
          ],
        ),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(7),
          child: InkWell(
              borderRadius: BorderRadius.circular(7),
              splashColor: spreadColor,
              onTap: () {
                print("Salut les jeunes");
              },
              child: Icon(
                Icons.add,
                size: 40,
              )),
        ),
      ),
    );
  }
}
