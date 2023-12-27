import 'package:flutter/material.dart';

import '../../custom_materials/theme.dart';
import '../LittleCard.dart';

class OthersOrderLineElement extends StatelessWidget {
  const OthersOrderLineElement(
      {super.key,
        required this.productName,
        required this.productPrice,
        required this.quantity});

  final int quantity;
  final String productName;
  final double productPrice;

  @override
  Widget build(BuildContext context) {
    final double totalPrice = productPrice * quantity;
    final CustomColors customColors =
    Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LittleCard(
                  littleCardColor: customColors.primary!,
                  leftMargin: 10.0,
                  text: "$quantity"),
              LittleCard(
                  littleCardColor: customColors.primary!,
                  flex: 5,
                  text: productName),
              LittleCard(
                  littleCardColor: customColors.primary!,
                  flex: 2,
                  text: "à $productPrice€/p"),
              LittleCard(
                  littleCardColor: customColors.primary!,
                  flex: 3,
                  rightMargin: 10.0,
                  text: "$totalPrice€"),
            ],
          ),
        ],
      ),
    );
  }
}