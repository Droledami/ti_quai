import 'package:flutter/material.dart';

class FlexIconButton extends StatelessWidget {
  const FlexIconButton(
      {super.key,
        required this.onTap,
        required this.color,
        required this.spreadColor,
        required this.iconData,
        this.flex = 1,
        this.marginLeft = 3,
        this.marginRight = 3,
        this.marginTop = 3,
        this.marginBottom = 6});

  final Function onTap;
  final Color color;
  final Color spreadColor;
  final IconData iconData;
  final int flex;
  final double marginLeft;
  final double marginRight;
  final double marginTop;
  final double marginBottom;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.only(
            left: marginLeft,
            right: marginRight,
            top: marginTop,
            bottom: marginBottom),
        child: Container(
          height: 70,
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
                onTap: () => onTap(),
                child: Icon(
                  iconData,
                  size: 40,
                )),
          ),
        ),
      ),
    );
  }
}