import 'package:flutter/material.dart';

import '../enums/PaymentMethod.dart';
import '../theme.dart';
import 'LittleCard.dart';
import 'TextDivider.dart';

class GreatTotal extends StatelessWidget {
  const GreatTotal({
    super.key,
    required this.paymentMethod,
    required this.totalPrice,
    this.onTap
  });

  final PaymentMethod paymentMethod;
  final double totalPrice;

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    String paymentMethodString = paymentMethod.name;
    final CustomColors customColors =
    Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              color: customColors.cardHalfTransparency!,
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              TextDivider(
                text: "Grand Total",
                color: customColors.tertiary!,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  children: [
                    LittleCard(
                          flex: 8,
                          height: 26,
                          leftMargin: 5,
                          rightMargin: 2,
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                          littleCardColor: customColors.special!,
                          text: "Règlement par $paymentMethodString"),
                    LittleCard(
                        flex: 3,
                        height: 26,
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        rightMargin: 5,
                        littleCardColor: customColors.special!,
                        text: "$totalPrice€"),
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