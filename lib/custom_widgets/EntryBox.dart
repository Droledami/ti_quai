import 'package:flutter/material.dart';

import '../enums/EntryType.dart';
import '../functions/functions.dart';
import '../theme.dart';

class EntryBox extends StatelessWidget {
  const EntryBox(
      {super.key,
      required this.orderEntryType,
      required this.maxLength,
      required this.placeholder,
        required this.textEditingController,
        this.textAlign = TextAlign.center,
        this.flex = 1,
        this.lines = 1,
      this.marginLeft = 0,
      this.marginRight = 0,
      this.marginTop = 6,
      this.marginBottom = 6});

  final int maxLength;
  final OrderEntry orderEntryType;
  final String placeholder;

  final int flex;
  final int lines;
  final TextAlign textAlign;

  final double marginLeft;
  final double marginRight;
  final double marginTop;
  final double marginBottom;

  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    CustomColors customColors = Theme.of(context).extension<CustomColors>()!;
    return Flexible(
      flex: flex,
      fit: FlexFit.loose,
      child: Padding(
        padding: EdgeInsets.only(
            top: marginTop,
            bottom: marginBottom,
            right: marginRight,
            left: marginLeft),
        child: Container(
          decoration: BoxDecoration(
              color: customColors.cardQuarterTransparency,
              borderRadius: BorderRadius.circular(7)),
          child: TextFormField(
            maxLines: lines,
            controller: textEditingController,
            textAlign: textAlign,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(left: 5, right: 5, bottom: orderEntryType == OrderEntry.tableNumber? 13 : 5),
              hintText: placeholder,
              counterText: "",
              border: InputBorder.none,
            ),
            style: TextStyle(color: Colors.black87, fontSize: 28),
            maxLength: maxLength,
            keyboardType: orderEntryToInputType(orderEntryType),
          ),
        ),
      ),
    );
  }
}
