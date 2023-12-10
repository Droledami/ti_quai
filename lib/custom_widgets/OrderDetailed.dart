import 'package:flutter/material.dart';
import 'package:ti_quai/main.dart';

import '../enums/ArticleType.dart';
import '../models/CustomerOrder.dart';
import '../theme.dart';
import 'GreatTotal.dart';
import 'OrderHeader.dart';
import 'OrderLineElement.dart';
import 'OthersOrderLineElement.dart';
import 'PromotionsSummary.dart';
import 'TextDivider.dart';

class OrderDetailed extends StatefulWidget {
  const OrderDetailed(
      {super.key,
        required this.order,
        required this.orderBoxId,
        required this.closeSelection});

  final CustomerOrder order;
  final int orderBoxId;
  final Function closeSelection;

  @override
  State<OrderDetailed> createState() => _OrderDetailedState();
}

class _OrderDetailedState extends State<OrderDetailed> {
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderHeader(
                tableNumber: widget.order.tableNumber,
                articleNumber: widget.order.orderElements.length,
                orderDate: widget.order.date,
                closeSelection: widget.closeSelection,
                isEditMode: false,
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: (){
                  Navigator.pushNamed(context, "/order", arguments: EditOrAddScreenArguments(orderId: widget.order.id, isEditMode: true));
                },
                child: Column(
                  children: [
                    TextDivider(text: "Menu", color: customColors.tertiary!),
                    Column(
                        children: widget.order.orderElements.map((orderElement) {
                          if (orderElement.articleType == ArticleType.menu) {
                            return OrderLineElement(orderElement: orderElement);
                          } else {
                            return SizedBox.shrink();
                          }
                        }).toList()),
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
                    Builder(builder: (context) {
                      if (hasPromotion) {
                        return Column(
                          children: [
                            TextDivider(
                                text: "Promotions", color: customColors.tertiary!),
                            PromotionsSummary(
                                totalDiscount: widget.order.totalDiscount,
                                orderElements: widget.order.orderElements),
                          ],
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
                    GreatTotal(
                        paymentMethod: widget.order.paymentMethod,
                        totalPrice: widget.order.totalPrice),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}