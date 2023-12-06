import 'package:flutter/material.dart';

import '../functions/functions.dart';
import '../theme.dart';
import 'LittleCard.dart';

class OrderHeader extends StatelessWidget {
  const OrderHeader(
      {super.key,
        required this.tableNumber,
        required this.articleNumber,
        required this.orderDate,
        required this.closeSelection});

  final int tableNumber;
  final int articleNumber;
  final DateTime orderDate;
  final Function closeSelection;

  @override
  Widget build(BuildContext context) {
    final orderTime = getHourAndMinuteString(orderDate);
    final CustomColors customColors =
    Theme.of(context).extension<CustomColors>()!;
    return GestureDetector(
      onTap: () {
        closeSelection();
      },
      child: Container(
        padding: EdgeInsets.only(left: 0, right: 0, top: 2, bottom: 5),
        decoration: BoxDecoration(
          color: customColors.cardHalfTransparency!,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding:
              const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
              leading: Text(
                'Table $tableNumber',
                style: TextStyle(
                  height: 1,
                  fontSize: 30,
                ),
              ),
              title: Text(
                articleNumber > 1
                    ? "$articleNumber articles"
                    : "$articleNumber article",
                style: TextStyle(
                  height: 1,
                  fontSize: 24,
                ),
              ),
              trailing: Text(
                orderTime,
                style: TextStyle(
                  height: 1,
                  fontSize: 24,
                ),
              ),
            ),
            Row(
              children: [
                LittleCard(
                    littleCardColor: customColors.primaryLight!,
                    leftMargin: 10.0,
                    text: "Qté"),
                LittleCard(
                    littleCardColor: customColors.primaryLight!, text: "A-Z"),
                LittleCard(
                    littleCardColor: customColors.primaryLight!, text: "N°"),
                LittleCard(
                    littleCardColor: customColors.primaryLight!, text: "a-z"),
                LittleCard(
                    littleCardColor: customColors.primaryLight!, text: "Sup."),
                LittleCard(
                    littleCardColor: customColors.primaryLight!,
                    flex: 3,
                    text: "Prix U."),
                LittleCard(
                    littleCardColor: customColors.primaryLight!,
                    flex: 3,
                    rightMargin: 10.0,
                    text: "Total"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}