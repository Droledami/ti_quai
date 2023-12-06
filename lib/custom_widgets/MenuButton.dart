import 'package:flutter/material.dart';

import '../theme.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      width: 55,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.00, -1.00),
          end: const Alignment(0, 1),
          stops: const [0.5, 8.0],
          colors: [
            customColors.primaryLight!,
            customColors.primary!,
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Builder(builder: (context) {
        return IconButton(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(2),
          icon: const Icon(Icons.menu_rounded),
          iconSize: 55,
          color: customColors.primaryDark!,
          onPressed: () => {Scaffold.of(context).openDrawer()},
        );
      }),
    );
  }
}