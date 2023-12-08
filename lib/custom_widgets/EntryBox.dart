import 'package:flutter/material.dart';

import '../enums/EntryType.dart';
import '../functions/functions.dart';
import '../theme.dart';

class EntryBox extends StatefulWidget {
  const EntryBox(
      {super.key,
      required this.orderEntryType,
      required this.initialValue,
      required this.maxLength,
      required this.placeholder,
      this.marginLeft = 0,
      this.marginRight = 0,
      this.marginTop = 6,
      this.marginBottom = 6});

  final int maxLength;
  final OrderEntry orderEntryType;
  final String initialValue;
  final String placeholder;

  final double marginLeft;
  final double marginRight;
  final double marginTop;
  final double marginBottom;

  @override
  State<EntryBox> createState() => _EntryBoxState();
}

class _EntryBoxState extends State<EntryBox> {
  @override
  void initState() {
    _entry = widget.initialValue;
    super.initState();
  }

  String _entry = "";

  @override
  Widget build(BuildContext context) {
    CustomColors customColors = Theme.of(context).extension<CustomColors>()!;
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
            top: widget.marginTop,
            bottom: widget.marginBottom,
            right: widget.marginRight,
            left: widget.marginLeft),
        child: Container(
          decoration: BoxDecoration(
              color: customColors.cardQuarterTransparency,
              borderRadius: BorderRadius.circular(7)),
          child: TextFormField(
            onChanged: (value) {},
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: widget.placeholder,
              counterText: "",
              border: InputBorder.none,
            ),
            style: TextStyle(color: Colors.black87, fontSize: 28),
            maxLength: widget.maxLength,
            initialValue: _entry,
            keyboardType: orderEntryToInputType(widget.orderEntryType),
          ),
        ),
      ),
    );
  }
}
