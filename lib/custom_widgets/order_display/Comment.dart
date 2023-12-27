import 'package:flutter/material.dart';

import '../../custom_materials/theme.dart';

class Comment extends StatelessWidget {
  const Comment({super.key, this.isExtra = false, required this.comment});

  final bool isExtra;
  final String comment;

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
    Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: EdgeInsets.only(left: 25, top: 2, bottom: 5, right: 10),
      child: Container(
        width: 450,
        padding: EdgeInsets.only(left: 2, right: 2, top: 3, bottom: 2),
        decoration: BoxDecoration(
          color: customColors.special!,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          '${isExtra ? "Supplément" : "Commentaire"}: $comment',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}