import 'package:flutter/material.dart';

class SizedIconButton extends StatelessWidget {
  const SizedIconButton(
      {super.key,
        required this.color,
        required this.spreadColor,
        required this.iconData,
        required this.onTap,
        this.iconSize = 40});

  final Color color;
  final Color spreadColor;
  final IconData iconData;
  final Function onTap;
  final double iconSize;

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
              onTap: () => onTap(),
              child: Icon(
                iconData,
                size: iconSize,
              )),
        ),
      ),
    );
  }
}
