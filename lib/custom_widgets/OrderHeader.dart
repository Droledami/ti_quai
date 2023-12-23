import 'package:flutter/material.dart';

import '../enums/EntryType.dart';
import '../processes/functions.dart';
import '../theme.dart';
import 'EntryBox.dart';
import 'LittleCard.dart';

class OrderHeader extends StatelessWidget {
  const OrderHeader(
      {super.key,
      required this.tableNumber,
      required this.articleNumber,
      required this.orderDate,
      required this.isEditMode,
      this.textEditingController,
      this.closeSelection})
      : assert(((textEditingController != null && isEditMode) || !isEditMode),
            "If isEditMode is true, then a textEditingController is required, if a controller is set but isEditMode is set to false, the controller will be useless.");

  final int tableNumber;
  final int articleNumber;
  final DateTime orderDate;
  final bool isEditMode;
  final Function? closeSelection;
  final TextEditingController? textEditingController;

  @override
  Widget build(BuildContext context) {
    final orderTime = getHourAndMinuteString(orderDate);
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return GestureDetector(
      onTap: () {
        if (closeSelection != null) closeSelection!();
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
            Row(children: [
              Builder(builder: (context) {
                if (isEditMode) {
                  return Expanded(
                    flex: 6,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, top: 7, bottom: 10),
                          child: Text(
                            'Table',
                            style: TextStyle(
                              height: 1,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        EntryBox(
                          validator: (value) {
                            if (value != null &&
                                RegExp(r"^[1-9][0-9]?$").hasMatch(value)) {
                              return null;
                            } else {
                              return "Erreur N°";
                            }
                          },
                          marginTop: 7,
                          marginRight: 20,
                          textEditingController: textEditingController!,
                          orderEntryType: QuaiEntry.tableNumber,
                          maxLength: 2,
                          placeholder: "n°",
                        ),
                      ],
                    ),
                  );
                } else {
                  return Expanded(
                    flex: 5,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 10, top: 7, bottom: 10),
                      child: Text(
                        'Table $tableNumber',
                        style: TextStyle(
                          height: 1,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  );
                }
              }),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(left:5),
                  child: Text(
                    articleNumber > 1
                        ? "$articleNumber articles"
                        : "$articleNumber article",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      height: 1,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                  child: Text(
                    orderTime,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      height: 1,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ]),
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
