import 'package:flutter/material.dart';

import '../../custom_materials/decoration_functions.dart';
import '../../custom_materials/theme.dart';

class ActionIconButton extends StatelessWidget {
  const ActionIconButton({
    super.key,
    required this.iconData,
    required this.onPressed,
  });

  final IconData iconData;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
    Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Container(
        height: 55,
        width: 55,
        decoration: buildAppBarDecoration(customColors),
        child: IconButton(
          onPressed: () => onPressed(),
          icon: Icon(iconData, size: 36),
        ),
      ),
    );
  }
}